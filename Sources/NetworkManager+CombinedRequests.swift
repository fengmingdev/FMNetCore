//
//  NetworkManager+CombinedRequests.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine
import Moya

extension NetworkManager {
    /// 组合两个请求并处理弱网情况
    func combinedRequest<T1: Decodable, T2: Decodable,
                         R1: APIRequest, R2: APIRequest>(
        _ request1: R1,
        _ request2: R2
    ) -> AnyPublisher<(T1, T2), NetworkError> {
        return combinedRequest(request1, request2, useCache: false)
    }
    
    /// 组合两个请求并处理弱网情况
    func combinedRequest<T1: Decodable, T2: Decodable,
                         R1: APIRequest, R2: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        useCache: Bool
    ) -> AnyPublisher<(T1, T2), NetworkError> {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))"
            if let cachedData = getCacheManager().getMemoryCache(forKey: cacheKey) as? (T1, T2) {
                return Just(cachedData)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        // 检查是否需要加载视图
        let needsLoading = request1.needsLoadingIndicator || request2.needsLoadingIndicator
        
        // 创建延迟显示加载视图的Publisher
        let loadingPublisher = Just(())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                if needsLoading {
                    // 显示加载指示器并保存任务ID
                    let _ = LoadingIndicatorManager.shared.showLoading()
                }
            })
            .eraseToAnyPublisher()
        
        // 保存延迟加载的引用，用于取消
        var loadingCancellable: AnyCancellable?
        
        // 创建两个请求的Publisher
        let publisher1: AnyPublisher<T1, NetworkError> = requestWithWeakNetworkHandling(request1)
        let publisher2: AnyPublisher<T2, NetworkError> = requestWithWeakNetworkHandling(request2)
        
        // 组合请求
        let combinedPublisher = Publishers.Zip(publisher1, publisher2)
            .handleEvents(
                receiveCompletion: { _ in
                    loadingCancellable?.cancel()
                    if needsLoading {
                        LoadingIndicatorManager.shared.hideLoading()
                    }
                },
                receiveCancel: {
                    loadingCancellable?.cancel()
                    if needsLoading {
                        LoadingIndicatorManager.shared.hideLoading()
                    }
                }
            )
            .map { result in
                // 如果启用缓存，存储响应到缓存
                if useCache {
                    let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))"
                    self.getCacheManager().setMemoryCache(result as AnyObject, forKey: cacheKey)
                }
                return result
            }
            .eraseToAnyPublisher()
        
        // 启动延迟加载任务
        if needsLoading {
            loadingCancellable = loadingPublisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
        
        return combinedPublisher
    }
    
    /// 组合三个请求
    func combinedRequest<T1: Decodable, T2: Decodable, T3: Decodable,
                         R1: APIRequest, R2: APIRequest, R3: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        _ request3: R3
    ) -> AnyPublisher<(T1, T2, T3), NetworkError> {
        return combinedRequest(request1, request2, request3, useCache: false)
    }
    
    /// 组合三个请求
    func combinedRequest<T1: Decodable, T2: Decodable, T3: Decodable,
                         R1: APIRequest, R2: APIRequest, R3: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        _ request3: R3,
        useCache: Bool
    ) -> AnyPublisher<(T1, T2, T3), NetworkError> {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))-\(type(of: request3)).\(String(describing: request3))"
            if let cachedData = getCacheManager().getMemoryCache(forKey: cacheKey) as? (T1, T2, T3) {
                return Just(cachedData)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        let needsLoading = request1.needsLoadingIndicator || request2.needsLoadingIndicator || request3.needsLoadingIndicator
        
        let loadingPublisher = Just(())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: {
                if needsLoading {
                    // 显示加载指示器并保存任务ID
                    let _ = LoadingIndicatorManager.shared.showLoading()
                }
            })
            .eraseToAnyPublisher()
        
        var loadingCancellable: AnyCancellable?
        
        let publisher1: AnyPublisher<T1, NetworkError> = requestWithWeakNetworkHandling(request1)
        let publisher2: AnyPublisher<T2, NetworkError> = requestWithWeakNetworkHandling(request2)
        let publisher3: AnyPublisher<T3, NetworkError> = requestWithWeakNetworkHandling(request3)
        
        let combinedPublisher = Publishers.Zip3(publisher1, publisher2, publisher3)
            .handleEvents(
                receiveCompletion: { _ in
                    loadingCancellable?.cancel()
                    if needsLoading {
                        LoadingIndicatorManager.shared.hideLoading()
                    }
                },
                receiveCancel: {
                    loadingCancellable?.cancel()
                    if needsLoading {
                        LoadingIndicatorManager.shared.hideLoading()
                    }
                }
            )
            .map { result in
                // 如果启用缓存，存储响应到缓存
                if useCache {
                    let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))-\(type(of: request3)).\(String(describing: request3))"
                    self.getCacheManager().setMemoryCache(result as AnyObject, forKey: cacheKey)
                }
                return result
            }
            .eraseToAnyPublisher()
        
        if needsLoading {
            loadingCancellable = loadingPublisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
        
        return combinedPublisher
    }
    
    /// 为单个请求添加弱网处理
    private func requestWithWeakNetworkHandling<T: Decodable, R: APIRequest>(
        _ request: R
    ) -> AnyPublisher<T, NetworkError> {
        // 记录请求开始时间
        let startTime = Date()
        
        // 检查网络状态
        return checkNetworkAvailability(for: request)
            .flatMap { [weak self] (_: Void) -> AnyPublisher<T, NetworkError> in
                guard let self = self else {
                    return Fail(error: .other(error: NSError(domain: "NetworkManager", code: -1))).eraseToAnyPublisher()
                }
                
                return self.request(request)
                    .handleEvents(receiveOutput: { _ in
                        // 计算响应时间
                        let responseTime = Date().timeIntervalSince(startTime)
                        // 记录请求完成时间，用于弱网分析
                        self.detectSlowRequest(for: request, responseTime: responseTime)
                    })
                    .eraseToAnyPublisher()
            }
            .retry(3)
            .eraseToAnyPublisher()
    }
}