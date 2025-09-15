//
//  NetworkManager.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine
// 直接导入需要的类型而不是通过模块导入

/// 网络管理器，负责处理应用中的所有网络请求
/// 使用单例模式确保全局唯一实例
public final class NetworkManager {
    // 单例实例
    public static let shared = NetworkManager()
    
    // 网络配置
    public var config: NetworkConfig
    
    // Moya 提供者
    public let provider: MoyaProvider<MultiTarget>
    
    // 存储订阅
    public var cancellables = Set<AnyCancellable>()
    
    // 缓存管理器
    public let cacheManager = CacheManager.shared
    
    // 拦截器管理器
    public let interceptorManager = NetworkInterceptorManager.shared
    
    // 重试策略
    private var retryStrategy: RetryStrategy = AdaptiveRetryStrategy()
    
    // 提供对缓存管理器的访问方法
    public func getCacheManager() -> CacheManager {
        return cacheManager
    }
    
    // 私有初始化方法，确保单例唯一性
    public init(config: NetworkConfig = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)) {
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
        
        // 监听网络状态变化
        setupNetworkStatusObserver()
    }
    
    // 用于测试的初始化方法
    public convenience init(config: NetworkConfig, isTest: Bool) {
        self.init(config: config)
    }
    
    /// 设置网络状态监听
    private func setupNetworkStatusObserver() {
        // 监听网络状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NSNotification.Name("NetworkStatusChanged"),
            object: nil
        )
    }
    
    /// 网络状态变化处理
    @objc private func networkStatusChanged() {
        // 检查网络是否恢复
        if case .wifi = ReachabilityManager.shared.networkStatus {
            // 网络恢复，开始同步离线请求
            OfflineRequestManager.shared.syncOfflineRequests()
        }
    }
    
    /// 设置重试策略
    /// - Parameter strategy: 重试策略
    public func setRetryStrategy(_ strategy: RetryStrategy) {
        self.retryStrategy = strategy
    }
    
    /// 获取当前重试策略
    /// - Returns: 当前重试策略
    public func getRetryStrategy() -> RetryStrategy {
        return self.retryStrategy
    }
    
    /// 创建URLSession配置
    /// - Parameter config: 网络配置
    /// - Returns: URLSessionConfiguration实例
    public static func createURLSessionConfiguration(config: NetworkConfig) -> URLSessionConfiguration {
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
    public static func createServerTrustManager(config: NetworkConfig) -> ServerTrustManager? {
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
    public static func createSession(configuration: URLSessionConfiguration, config: NetworkConfig) -> Session {
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
    public func setupDefaultInterceptors() {
        // 添加日志拦截器
        interceptorManager.addInterceptor(LoggingInterceptor())
        
        // 添加性能监控拦截器
        interceptorManager.addInterceptor(PerformanceInterceptor())
        
        // 添加缓存拦截器
        interceptorManager.addInterceptor(CacheInterceptor())
    }
    
    /// 设置网络可达性监测
    /// 启动网络状态监测并订阅状态变化
    public func setupReachability() {
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
    public func handleNetworkStatusChange(_ status: NetworkStatus) {
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
    public func request<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError> {
        return self.request(request, useCache: false)
    }
    
    /// 发送请求，支持缓存
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    ///   - useCache: 是否使用缓存
    /// - Returns: 返回包含解析后数据的Publisher
    public func request<T: Decodable, R: APIRequest>(_ request: R, useCache: Bool) -> AnyPublisher<T, NetworkError> {
        // 检查网络状态
        return checkNetworkAvailability(for: request)
            .catch { [weak self] error -> AnyPublisher<Void, NetworkError> in
                // 网络不可用，检查是否支持离线模式
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // 如果是网络不可达错误，尝试使用缓存或离线模式
                if case .networkUnreachable = error {
                    // 检查是否有缓存数据
                    if useCache, let cachedData = self.getCacheData(for: request) as? T {
                        // 我们不能在这里直接返回缓存数据，因为catch操作符需要返回Void类型的Publisher
                        // 缓存数据的处理应该在其他地方进行
                        // 为了简化，我们暂时忽略缓存数据，直接返回错误
                        return Fail(error: NetworkError.networkUnreachable).eraseToAnyPublisher()
                    }
                    
                    // 保存请求到离线队列
                    self.saveOfflineRequest(request)
                    
                    // 返回离线错误
                    return Fail(error: NetworkError.networkUnreachable).eraseToAnyPublisher()
                }
                
                return Fail(error: error).eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ -> AnyPublisher<Response, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.other(error: NSError(domain: "NetworkManager", code: -1))).eraseToAnyPublisher()
                }
                
                let target = MultiTarget(request.asTarget())
                
                // 生成请求ID
                let requestId = UUID().uuidString
                
                // 开始性能监控
                let startTime = PerformanceMonitor.shared.startMonitoring(
                    requestId: requestId,
                    url: "\(target.baseURL)\(target.path)",
                    method: target.method.rawValue
                )
                
                // 调用拦截器 - 请求即将发送
                self.interceptorManager.willSendRequest(request, target: target)
                
                return Future<Response, NetworkError> { promise in
                    self.provider.request(target) { result in
                        // 调用拦截器 - 请求完成
                        self.interceptorManager.didCompleteRequest(request, target: target, result: result)
                        
                        switch result {
                        case .success(let response):
                            // 结束性能监控
                            PerformanceMonitor.shared.endMonitoring(
                                requestId: requestId,
                                url: "\(target.baseURL)\(target.path)",
                                method: target.method.rawValue,
                                startTime: startTime,
                                dataSize: response.data.count
                            )
                            
                            // 调用拦截器 - 请求成功
                            self.interceptorManager.didSucceedRequest(request, target: target, response: response)
                            
                            // 如果启用缓存，存储响应到缓存
                            if useCache {
                                let cacheKey = "\(type(of: request)).\(String(describing: request))"
                                self.cacheManager.setMemoryCache(response.data as AnyObject, forKey: cacheKey)
                            }
                            
                            promise(.success(response))
                        case .failure(let error):
                            // 结束性能监控（失败情况）
                            PerformanceMonitor.shared.endMonitoring(
                                requestId: requestId,
                                url: "\(target.baseURL)\(target.path)",
                                method: target.method.rawValue,
                                startTime: startTime
                            )
                            
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
            .smartRetry(
                maxRetries: request.retryCount ?? config.maxRetryCount,
                strategy: request.retryStrategy ?? self.retryStrategy,
                errorTransformer: { $0 }
            )
            .eraseToAnyPublisher()
    }
    
    /// 发送请求并管理加载视图
    /// 如果请求需要显示加载指示器，则在请求开始0.5秒后显示加载视图
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    /// - Returns: 返回包含解析后数据的Publisher
    public func requestWithLoading<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError> {
        guard request.needsLoadingIndicator else {
            return self.request(request)
        }
        
        // 创建延迟显示加载视图的Publisher
        let loadingPublisher = Just(())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                // 显示加载指示器并保存任务ID
                let _ = LoadingIndicatorManager.shared.showLoading()
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
    
    /// 获取缓存数据
    /// - Parameter request: 请求对象
    /// - Returns: 缓存数据
    private func getCacheData<R: APIRequest>(for request: R) -> AnyObject? {
        let cacheKey = "\(type(of: request)).\(String(describing: request))"
        return cacheManager.getMemoryCache(forKey: cacheKey)
    }
    
    /// 保存离线请求
    /// - Parameter request: 请求对象
    private func saveOfflineRequest<R: APIRequest>(_ request: R) /*where R: Encodable*/ {
        // 将请求序列化为数据
        /*guard let requestData = try? JSONEncoder().encode(request) else {
            return
        }
        
        // 创建离线请求
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        let baseURLString = EnvironmentManager.shared.getConfig(for: currentEnvironment)?.baseURL.absoluteString ?? "https://api.example.com"
        let offlineEnvironmentConfig = OfflineEnvironmentConfig(type: currentEnvironment, baseURL: baseURLString)
        
        let offlineRequest = OfflineRequest(
            requestData: requestData,
            targetEnvironment: offlineEnvironmentConfig
        )
        
        // 添加到离线请求管理器
        OfflineRequestManager.shared.addRequest(offlineRequest)*/
    }
}
