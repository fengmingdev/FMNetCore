//
//  NetworkManager.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine
import Moya
import Alamofire

/// 网络管理器，负责处理应用中的所有网络请求
/// 使用单例模式确保全局唯一实例
final class NetworkManager {
    // 单例实例
    static let shared = NetworkManager()
    
    // 网络配置
    var config: NetworkConfig
    
    // Moya 提供者
    internal let provider: MoyaProvider<MultiTarget>
    
    // 存储订阅
    internal var cancellables = Set<AnyCancellable>()
    
    // 缓存管理器
    private let cacheManager = CacheManager.shared
    
    // 拦截器管理器
    internal let interceptorManager = NetworkInterceptorManager.shared
    
    // 提供对缓存管理器的访问方法
    internal func getCacheManager() -> CacheManager {
        return cacheManager
    }
    
    // 私有初始化方法，确保单例唯一性
    private init(config: NetworkConfig = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)) {
        self.config = config
        
        // 创建URLSession配置
        let configuration = Self.createURLSessionConfiguration(config: config)
        
        // 创建Moya提供者
        var plugins: [PluginType] = []
        
        // 如果开启日志，添加日志插件
        if config.enableLogging {
            plugins.append(MoyaNetworkLoggerPlugin())
        }
        
        // 创建自定义session
        let session = Self.createSession(
            configuration: configuration,
            config: config
        )
        
        self.provider = MoyaProvider<MultiTarget>(
            session: session,
            plugins: plugins
        )
        
        // 启动网络监测
        setupReachability()
        
        // 添加默认拦截器
        setupDefaultInterceptors()
    }
    
    // 用于测试的初始化方法
    internal convenience init(config: NetworkConfig, isTest: Bool) {
        self.init(config: config)
    }
    
    /// 创建URLSession配置
    /// - Parameter config: 网络配置
    /// - Returns: URLSessionConfiguration实例
    private static func createURLSessionConfiguration(config: NetworkConfig) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        
        // 如果配置了代理，设置代理
        if let proxyConfig = config.proxyConfig {
            var proxyDictionary: [AnyHashable: Any] = [:]
            
            // HTTP代理配置
            if proxyConfig.httpEnabled {
                proxyDictionary["HTTPEnable"] = 1
                proxyDictionary["HTTPProxy"] = proxyConfig.host
                proxyDictionary["HTTPPort"] = proxyConfig.port
            }
            
            // HTTPS代理配置
            if proxyConfig.httpsEnabled {
                proxyDictionary["HTTPSEnable"] = 1
                proxyDictionary["HTTPSProxy"] = proxyConfig.host
                proxyDictionary["HTTPSPort"] = proxyConfig.port
            }
            
            // 如果有认证信息，添加到字典中
            if let username = proxyConfig.username {
                proxyDictionary["HTTPProxyUserName"] = username
            }
            
            if let password = proxyConfig.password {
                proxyDictionary["HTTPProxyPassword"] = password
            }
            
            configuration.connectionProxyDictionary = proxyDictionary
        }
        
        return configuration
    }
    
    /// 创建服务器信任管理器
    /// - Parameter config: 网络配置
    /// - Returns: ServerTrustManager实例或nil
    private static func createServerTrustManager(config: NetworkConfig) -> ServerTrustManager? {
        // 如果允许无效证书或配置了证书锁定，创建服务器信任管理器
        if config.allowInvalidCertificates || config.sslCertificatePath != nil {
            // 创建评估器
            var evaluators: [String: ServerTrustEvaluating] = [:]
            
            // 对所有主机使用自定义评估器
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                evaluators["*"] = CustomServerTrustEvaluator(config: config)
            } else {
                evaluators["*"] = LegacyCustomServerTrustEvaluator(config: config)
            }
            
            return ServerTrustManager(evaluators: evaluators)
        }
        
        return nil
    }
    
    /// 创建Session
    /// - Parameters:
    ///   - configuration: URLSession配置
    ///   - config: 网络配置
    /// - Returns: Session实例
    private static func createSession(configuration: URLSessionConfiguration, config: NetworkConfig) -> Session {
        // 如果配置了重定向或证书验证，创建相应的处理器
        if !config.allowRedirects || config.sslCertificatePath != nil || config.allowInvalidCertificates {
            // 创建重定向处理器
            let redirectHandler: RedirectHandler? = config.allowRedirects ? CustomRedirectHandler(config: config) : nil
            
            // 创建服务器信任管理器
            let serverTrustManager: ServerTrustManager? = Self.createServerTrustManager(config: config)
            
            return Session(
                configuration: configuration,
                startRequestsImmediately: false,
                serverTrustManager: serverTrustManager,
                redirectHandler: redirectHandler
            )
        } else {
            return Session(
                configuration: configuration,
                startRequestsImmediately: false
            )
        }
    }
    
    /// 设置默认拦截器
    private func setupDefaultInterceptors() {
        // 添加日志拦截器
        interceptorManager.addInterceptor(LoggingInterceptor())
        
        // 添加性能监控拦截器
        interceptorManager.addInterceptor(PerformanceInterceptor())
        
        // 添加缓存拦截器
        interceptorManager.addInterceptor(CacheInterceptor())
    }
    
    /// 设置网络可达性监测
    /// 启动网络状态监测并订阅状态变化
    private func setupReachability() {
        ReachabilityManager.shared.startMonitoring()
        
        // 监听网络状态变化
        ReachabilityManager.shared.$networkStatus
            .sink { [weak self] status in
                self?.handleNetworkStatusChange(status)
            }
            .store(in: &cancellables)
    }
    
    /// 处理网络状态变化
    /// - Parameter status: 当前网络状态
    private func handleNetworkStatusChange(_ status: NetworkStatus) {
        switch status {
        case .unreachable:
            NotificationCenter.default.post(name: NSNotification.Name("NetworkUnreachable"), object: nil)
        case .cellular(let quality) where quality == .poor:
            NotificationCenter.default.post(name: NSNotification.Name("WeakNetworkDetected"), object: nil)
        default:
            break
        }
    }
    
    /// 发送请求
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    /// - Returns: 返回包含解析后数据的Publisher
    func request<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError> {
        return self.request(request, useCache: false)
    }
    
    /// 发送请求，支持缓存
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    ///   - useCache: 是否使用缓存
    /// - Returns: 返回包含解析后数据的Publisher
    func request<T: Decodable, R: APIRequest>(_ request: R, useCache: Bool) -> AnyPublisher<T, NetworkError> {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request)).\(String(describing: request))"
            if let cachedData = cacheManager.getMemoryCache(forKey: cacheKey) as? T {
                return Just(cachedData)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        // 检查网络状态
        return checkNetworkAvailability(for: request)
            .flatMap { [weak self] _ -> AnyPublisher<Response, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.other(error: NSError(domain: "NetworkManager", code: -1))).eraseToAnyPublisher()
                }
                
                let target = MultiTarget(request.asTarget())
                
                // 调用拦截器 - 请求即将发送
                self.interceptorManager.willSendRequest(request, target: target)
                
                return Future<Response, NetworkError> { promise in
                    self.provider.request(target) { result in
                        // 调用拦截器 - 请求完成
                        self.interceptorManager.didCompleteRequest(request, target: target, result: result)
                        
                        switch result {
                        case .success(let response):
                            // 调用拦截器 - 请求成功
                            self.interceptorManager.didSucceedRequest(request, target: target, response: response)
                            
                            // 如果启用缓存，存储响应到缓存
                            if useCache {
                                let cacheKey = "\(type(of: request)).\(String(describing: request))"
                                self.cacheManager.setMemoryCache(response.data as AnyObject, forKey: cacheKey)
                            }
                            
                            promise(.success(response))
                        case .failure(let error):
                            // 调用拦截器 - 请求失败
                            self.interceptorManager.didFailRequest(request, target: target, error: error)
                            
                            if case MoyaError.underlying(let underlyingError, _) = error {
                                if underlyingError is URLError,
                                   (underlyingError as? URLError)?.code == .timedOut {
                                    promise(.failure(.timeout))
                                    return
                                }
                            }
                            promise(.failure(.other(error: error)))
                        }
                    }
                }
                .timeout(.seconds(Int(self.config.timeoutInterval)), scheduler: DispatchQueue.main, options: nil, customError: { .timeout })
                .eraseToAnyPublisher()
            }
            .flatMap { (response: Response) -> AnyPublisher<T, NetworkError> in
                return ResponseHandler.shared.handleResponse(response)
            }
            .retry(3) // 自定义重试操作符
            .eraseToAnyPublisher()
    }
    
    /// 发送请求并管理加载视图
    /// 如果请求需要显示加载指示器，则在请求开始0.5秒后显示加载视图
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    /// - Returns: 返回包含解析后数据的Publisher
    func requestWithLoading<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError> {
        guard request.needsLoadingIndicator else {
            return self.request(request)
        }
        
        // 创建延迟显示加载视图的Publisher
        let loadingPublisher = Just(())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                LoadingIndicatorManager.shared.showLoading()
            })
            .eraseToAnyPublisher()
        
        // 保存延迟加载的引用，用于取消
        var loadingCancellable: AnyCancellable?
        
        // 发送实际请求
        let requestPublisher: AnyPublisher<T, NetworkError> = self.request(request)
            .handleEvents(
                receiveCompletion: { _ in
                    loadingCancellable?.cancel()
                    LoadingIndicatorManager.shared.hideLoading()
                },
                receiveCancel: {
                    loadingCancellable?.cancel()
                    LoadingIndicatorManager.shared.hideLoading()
                }
            )
            .eraseToAnyPublisher()
        
        // 启动延迟加载任务
        loadingCancellable = loadingPublisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        // 组合并返回
        return requestPublisher
    }
    
    /// 检查网络可用性
    /// - Parameter request: 请求对象
    /// - Returns: 返回Void的Publisher
    internal func checkNetworkAvailability<R: APIRequest>(for request: R) -> AnyPublisher<Void, NetworkError> {
        // 检查网络是否可达
        if case .unreachable = ReachabilityManager.shared.networkStatus {
            return Fail(error: NetworkError.networkUnreachable).eraseToAnyPublisher()
        }
        
        // 检查是否为弱网环境且请求不允许弱网
        if case .cellular(let quality) = ReachabilityManager.shared.networkStatus,
           quality == .poor,
           !request.allowsWeakNetwork {
            return Fail(error: NetworkError.weakNetworkNotAllowed).eraseToAnyPublisher()
        }
        
        return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
    
    /// 检查网络状态并处理弱网情况
    /// - Parameter request: API请求
    /// - Returns: 如果网络不可达或弱网不被允许，返回失败的Publisher
    private func checkNetworkStatus<T>(for request: any APIRequest) -> AnyPublisher<T, NetworkError>? {
        // 检查网络是否可达
        if case .unreachable = ReachabilityManager.shared.networkStatus {
            return Fail(error: NetworkError.networkUnreachable).eraseToAnyPublisher()
        }
        
        // 检查弱网情况
        if case .cellular(let quality) = ReachabilityManager.shared.networkStatus,
           quality == .poor,
           !request.allowsWeakNetwork {
            return Fail(error: NetworkError.weakNetworkNotAllowed).eraseToAnyPublisher()
        }
        
        return nil
    }
    
    /// 检测慢速请求
    /// - Parameters:
    ///   - request: 请求对象
    ///   - responseTime: 响应时间
    internal func detectSlowRequest<R: APIRequest>(for request: R, responseTime: TimeInterval) {
        // 如果响应时间超过阈值，认为是慢速请求
        if responseTime > 3.0 {
            // 发送慢速请求通知
            NotificationCenter.default.post(name: NSNotification.Name("SlowNetworkDetected"), object: nil)
        }
    }
}
