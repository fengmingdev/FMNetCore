//
//  ProtobufSupport.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
#if canImport(SwiftProtobuf)
import SwiftProtobuf
import Combine

/// Protobuf网络请求协议
/// 实现此协议的请求可以使用Protobuf进行序列化和反序列化
public protocol ProtobufAPIRequest: APIRequest {
    /// 请求的消息类型
    associatedtype RequestMessage: Message
    
    /// 响应的消息类型
    associatedtype ResponseMessage: Message
    
    /// 构建请求消息
    /// - Returns: 请求消息实例
    func buildRequestMessage() -> RequestMessage?
    
    /// 解析响应消息
    /// - Parameter data: 响应数据
    /// - Returns: 响应消息实例
    func parseResponseMessage(from data: Data) throws -> ResponseMessage
}

public extension ProtobufAPIRequest {
    /// 默认实现：不需要加载指示器
    var needsLoadingIndicator: Bool { false }
    
    /// 默认实现：允许弱网环境
    var allowsWeakNetwork: Bool { true }
    
    /// 默认实现：不重试
    var retryCount: Int? { return 0 }
}

/// Protobuf响应处理器
public final class ProtobufResponseHandler {
    public static let shared = ProtobufResponseHandler()
    private init() {}
    
    /// 处理Protobuf响应
    /// - Parameter data: 响应数据
    /// - Returns: 解析后的消息
    public func handleResponse<T: Message>(_ data: Data) throws -> T {
        return try T(serializedData: data)
    }
    
    /// 序列化Protobuf消息
    /// - Parameter message: 要序列化的消息
    /// - Returns: 序列化后的数据
    public func serializeMessage<T: Message>(_ message: T) throws -> Data {
        return try message.serializedData()
    }
    
    /// 从JSON数据解析Protobuf消息
    /// - Parameter jsonData: JSON数据
    /// - Returns: 解析后的消息
    public func parseFromJSON<T: Message>(_ jsonData: Data) throws -> T {
        return try T(jsonUTF8Data: jsonData)
    }
    
    /// 将Protobuf消息序列化为JSON
    /// - Parameter message: 要序列化的消息
    /// - Returns: JSON数据
    public func serializeToJSON<T: Message>(_ message: T) throws -> Data {
        return try message.jsonUTF8Data()
    }
}

/// Protobuf网络管理器扩展
extension NetworkManager {
    /// 发送Protobuf请求
    /// - Parameters:
    ///   - request: 符合ProtobufAPIRequest协议的请求对象
    /// - Returns: 返回包含解析后数据的Publisher
    public func request<P: ProtobufAPIRequest>(_ request: P) -> AnyPublisher<P.ResponseMessage, NetworkError> {
        return self.request(request, useCache: false)
    }
    
    /// 发送Protobuf请求，支持缓存
    /// - Parameters:
    ///   - request: 符合ProtobufAPIRequest协议的请求对象
    ///   - useCache: 是否使用缓存
    /// - Returns: 返回包含解析后数据的Publisher
    public func request<P: ProtobufAPIRequest>(_ request: P, useCache: Bool) -> AnyPublisher<P.ResponseMessage, NetworkError> {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request)).\(String(describing: request))"
            if let cachedData = cacheManager.getMemoryCache(forKey: cacheKey) as? Data {
                do {
                    let responseMessage = try request.parseResponseMessage(from: cachedData)
                    return Just(responseMessage)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                } catch {
                    // 如果解析缓存数据失败，继续发送网络请求
                    print("Failed to parse cached data: \(error)")
                }
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
            .flatMap { [weak self] (response: Response) -> AnyPublisher<P.ResponseMessage, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.other(error: NSError(domain: "NetworkManager", code: -1))).eraseToAnyPublisher()
                }
                
                return Future<P.ResponseMessage, NetworkError> { promise in
                    do {
                        let responseMessage = try request.parseResponseMessage(from: response.data)
                        promise(.success(responseMessage))
                    } catch {
                        promise(.failure(NetworkError.parsingError))
                    }
                }
                .eraseToAnyPublisher()
            }
            .retry(request.retryCount ?? 0)
            .eraseToAnyPublisher()
    }
    
    /// 发送Protobuf请求并管理加载视图
    /// 如果请求需要显示加载指示器，则在请求开始0.5秒后显示加载视图
    /// - Parameters:
    ///   - request: 符合ProtobufAPIRequest协议的请求对象
    /// - Returns: 返回包含解析后数据的Publisher
    public func requestWithLoading<P: ProtobufAPIRequest>(_ request: P) -> AnyPublisher<P.ResponseMessage, NetworkError> {
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
        let requestPublisher: AnyPublisher<P.ResponseMessage, NetworkError> = self.request(request)
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
    
    /// 组合两个Protobuf请求
    /// - Parameters:
    ///   - request1: 第一个Protobuf请求
    ///   - request2: 第二个Protobuf请求
    /// - Returns: 返回包含两个解析后数据的Publisher
    public func combinedProtobufRequest<P1: ProtobufAPIRequest, P2: ProtobufAPIRequest>(
        _ request1: P1,
        _ request2: P2
    ) -> AnyPublisher<(P1.ResponseMessage, P2.ResponseMessage), NetworkError> {
        let publisher1 = self.request(request1)
        let publisher2 = self.request(request2)
        
        return publisher1.zip(publisher2)
            .eraseToAnyPublisher()
    }
    
    /// 组合三个Protobuf请求
    /// - Parameters:
    ///   - request1: 第一个Protobuf请求
    ///   - request2: 第二个Protobuf请求
    ///   - request3: 第三个Protobuf请求
    /// - Returns: 返回包含三个解析后数据的Publisher
    public func combinedProtobufRequest<P1: ProtobufAPIRequest, P2: ProtobufAPIRequest, P3: ProtobufAPIRequest>(
        _ request1: P1,
        _ request2: P2,
        _ request3: P3
    ) -> AnyPublisher<(P1.ResponseMessage, P2.ResponseMessage, P3.ResponseMessage), NetworkError> {
        let publisher1 = self.request(request1)
        let publisher2 = self.request(request2)
        let publisher3 = self.request(request3)
        
        return publisher1.zip(publisher2, publisher3)
            .eraseToAnyPublisher()
    }
}

#endif