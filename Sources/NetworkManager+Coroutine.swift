//
//  NetworkManager+Coroutine.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya
#if canImport(UIKit)
import UIKit
#endif

/// 任务包装器，用于管理任务生命周期
class ManagedTask {
    private let cancelBlock: (() -> Void)
    
    /// 初始化任务包装器
    /// - Parameter cancelBlock: 取消任务的回调闭包
    init(cancelBlock: @escaping () -> Void) {
        self.cancelBlock = cancelBlock
    }
    
    /// 取消任务
    func cancel() {
        cancelBlock()
    }
}

/// 协程管理器（兼容旧版Swift和Moya）
/// 用于管理网络请求任务的生命周期，支持任务的启动、取消等操作
final class CoroutineManager {
    /// 单例实例
    static let shared = CoroutineManager()
    
    /// 私有初始化方法，确保单例唯一性
    private init() {}
    
    // 存储当前活跃的任务
    private var activeTasks = Set<UUID>()
    private var taskMap = [UUID: ManagedTask]()
    private let lock = NSRecursiveLock()
    
    /// 启动并管理一个网络请求任务
    /// - Parameters:
    ///   - task: 任务创建闭包
    ///   - completion: 任务完成回调
    /// - Returns: 任务ID
    func runNetworkTask<T>(_ task: @escaping (@escaping (Result<T, Error>) -> Void) -> ManagedTask,
                         completion: @escaping (Result<T, Error>) -> Void) -> UUID {
        let taskId = UUID()
        
        // 创建任务
        let managedTask = task { [weak self] result in
            completion(result)
            self?.lock.lock()
            self?.activeTasks.remove(taskId)
            self?.taskMap.removeValue(forKey: taskId)
            self?.lock.unlock()
        }
        
        lock.lock()
        activeTasks.insert(taskId)
        taskMap[taskId] = managedTask
        lock.unlock()
        
        return taskId
    }
    
    /// 取消所有网络请求任务
    func cancelAllNetworkTasks() {
        lock.lock()
        taskMap.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        taskMap.removeAll()
        lock.unlock()
    }
    
    /// 取消指定的网络请求任务
    /// - Parameter taskId: 要取消的任务ID
    func cancelTask(_ taskId: UUID) {
        lock.lock()
        taskMap[taskId]?.cancel()
        activeTasks.remove(taskId)
        taskMap.removeValue(forKey: taskId)
        lock.unlock()
    }
}

extension NetworkManager {
    /// 发送请求，并自动管理加载视图
    /// 如果请求需要显示加载指示器，则在请求开始0.5秒后显示加载视图
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    ///   - completion: 请求完成回调
    /// - Returns: 任务ID
    func requestWithLoading<T: Decodable, R: APIRequest>(_ request: R,
                                                       completion: @escaping (Result<T, Error>) -> Void) -> UUID {
        return requestWithLoading(request, useCache: false, completion: completion)
    }
    
    /// 发送请求，并自动管理加载视图
    /// 如果请求需要显示加载指示器，则在请求开始0.5秒后显示加载视图
    /// - Parameters:
    ///   - request: 符合APIRequest协议的请求对象
    ///   - useCache: 是否使用缓存
    ///   - completion: 请求完成回调
    /// - Returns: 任务ID
    func requestWithLoading<T: Decodable, R: APIRequest>(_ request: R,
                                                       useCache: Bool,
                                                       completion: @escaping (Result<T, Error>) -> Void) -> UUID {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request)).\(String(describing: request))"
            if let cachedData = CacheManager.shared.getMemoryCache(forKey: cacheKey) as? T {
                completion(.success(cachedData))
                return UUID() // 返回一个虚拟的UUID
            }
        }
        
        // 创建加载视图计时器
        var loadingTimer: Timer?
        let needsLoading = request.needsLoadingIndicator
        var cancellable: Cancellable?
        
        if needsLoading {
            // 延迟0.5秒显示加载视图
            loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                DispatchQueue.main.async {
                    #if canImport(UIKit)
                    LoadingIndicatorManager.shared.showLoading()
                    #endif
                }
            }
        }
        
        // 创建请求任务
        let task = { [weak self] (completion: @escaping (Result<T, Error>) -> Void) -> ManagedTask in
            guard let self = self else {
                completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return ManagedTask(cancelBlock: {})
            }
            
            let target = MultiTarget(request.asTarget())
            
            // 调用拦截器 - 请求即将发送
            self.interceptorManager.willSendRequest(request, target: target)
            
            cancellable = self.provider.request(target) { result in
                // 取消加载计时器并隐藏加载视图
                loadingTimer?.invalidate()
                if needsLoading {
                    DispatchQueue.main.async {
                        #if canImport(UIKit)
                        LoadingIndicatorManager.shared.hideLoading()
                        #endif
                    }
                }
                
                // 调用拦截器 - 请求完成
                self.interceptorManager.didCompleteRequest(request, target: target, result: result)
                
                switch result {
                case .success(let response):
                    // 调用拦截器 - 请求成功
                    self.interceptorManager.didSucceedRequest(request, target: target, response: response)
                    
                    do {
                        let value = try ResponseHandler.shared.handleResponseSync(response) as T
                        
                        // 如果启用缓存，存储响应到缓存
                        if useCache {
                            let cacheKey = "\(type(of: request)).\(String(describing: request))"
                            CacheManager.shared.setMemoryCache(value as AnyObject, forKey: cacheKey)
                        }
                        
                        completion(.success(value))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    // 调用拦截器 - 请求失败
                    self.interceptorManager.didFailRequest(request, target: target, error: error)
                    
                    completion(.failure(error))
                }
            }
            
            // 返回包含取消逻辑的任务包装器
            return ManagedTask {
                cancellable?.cancel()
                loadingTimer?.invalidate()
                if needsLoading {
                    DispatchQueue.main.async {
                        #if canImport(UIKit)
                        LoadingIndicatorManager.shared.hideLoading()
                        #endif
                    }
                }
            }
        }
        
        // 交给协程管理器管理
        return CoroutineManager.shared.runNetworkTask(task, completion: completion)
    }
    
    /// 组合两个请求（基于回调方式）
    /// 并行发送两个请求，并在都完成时回调
    /// - Parameters:
    ///   - request1: 第一个请求
    ///   - request2: 第二个请求
    ///   - completion: 请求完成回调
    /// - Returns: 任务ID
    func combinedRequest<T1: Decodable, T2: Decodable,
                         R1: APIRequest, R2: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        completion: @escaping (Result<(T1, T2), Error>) -> Void
    ) -> UUID {
        return combinedRequest(request1, request2, useCache: false, completion: completion)
    }
    
    /// 组合两个请求（基于回调方式）
    /// 并行发送两个请求，并在都完成时回调
    /// - Parameters:
    ///   - request1: 第一个请求
    ///   - request2: 第二个请求
    ///   - useCache: 是否使用缓存
    ///   - completion: 请求完成回调
    /// - Returns: 任务ID
    func combinedRequest<T1: Decodable, T2: Decodable,
                         R1: APIRequest, R2: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        useCache: Bool,
        completion: @escaping (Result<(T1, T2), Error>) -> Void
    ) -> UUID {
        // 如果启用缓存，先尝试从缓存获取
        if useCache {
            let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))"
            if let cachedData = CacheManager.shared.getMemoryCache(forKey: cacheKey) as? (T1, T2) {
                completion(.success(cachedData))
                return UUID() // 返回一个虚拟的UUID
            }
        }
        
        let needsLoading = request1.needsLoadingIndicator || request2.needsLoadingIndicator
        var loadingTimer: Timer?
        var cancellable1: Cancellable?
        var cancellable2: Cancellable?
        var result1: T1?
        var result2: T2?
        var isCompleted = false
        
        if needsLoading {
            // 延迟0.5秒显示加载视图
            loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                DispatchQueue.main.async {
                    LoadingIndicatorManager.shared.showLoading()
                }
            }
        }
        
        // 创建组合请求任务
        let task = { [weak self] (completion: @escaping (Result<(T1, T2), Error>) -> Void) -> ManagedTask in
            guard let self = self else {
                completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return ManagedTask(cancelBlock: {})
            }
            
            // 处理请求结果的辅助方法
            func handleResults() {
                guard !isCompleted else { return }
                
                if let result1 = result1, let result2 = result2 {
                    isCompleted = true
                    
                    // 如果启用缓存，存储响应到缓存
                    if useCache {
                        let cacheKey = "\(type(of: request1)).\(String(describing: request1))-\(type(of: request2)).\(String(describing: request2))"
                        CacheManager.shared.setMemoryCache((result1, result2) as AnyObject, forKey: cacheKey)
                    }
                    
                    completion(.success((result1, result2)))
                }
            }
            
            // 发送第一个请求
            let target1 = MultiTarget(request1.asTarget())
            
            // 调用拦截器 - 第一个请求即将发送
            self.interceptorManager.willSendRequest(request1, target: target1)
            
            cancellable1 = self.provider.request(target1) { [weak self] result in
                guard let self = self, !isCompleted else { return }
                
                // 调用拦截器 - 第一个请求完成
                self.interceptorManager.didCompleteRequest(request1, target: target1, result: result)
                
                switch result {
                case .success(let response):
                    // 调用拦截器 - 第一个请求成功
                    self.interceptorManager.didSucceedRequest(request1, target: target1, response: response)
                    
                    do {
                        result1 = try ResponseHandler.shared.handleResponseSync(response) as T1
                        handleResults()
                    } catch {
                        isCompleted = true
                        completion(.failure(error))
                        cancellable2?.cancel()
                    }
                case .failure(let error):
                    // 调用拦截器 - 第一个请求失败
                    self.interceptorManager.didFailRequest(request1, target: target1, error: error)
                    
                    isCompleted = true
                    completion(.failure(error))
                    cancellable2?.cancel()
                }
            }
            
            // 发送第二个请求
            let target2 = MultiTarget(request2.asTarget())
            
            // 调用拦截器 - 第二个请求即将发送
            self.interceptorManager.willSendRequest(request2, target: target2)
            
            cancellable2 = self.provider.request(target2) { [weak self] result in
                guard let self = self, !isCompleted else { return }
                
                // 调用拦截器 - 第二个请求完成
                self.interceptorManager.didCompleteRequest(request2, target: target2, result: result)
                
                switch result {
                case .success(let response):
                    // 调用拦截器 - 第二个请求成功
                    self.interceptorManager.didSucceedRequest(request2, target: target2, response: response)
                    
                    do {
                        result2 = try ResponseHandler.shared.handleResponseSync(response) as T2
                        handleResults()
                    } catch {
                        isCompleted = true
                        completion(.failure(error))
                        cancellable1?.cancel()
                    }
                case .failure(let error):
                    // 调用拦截器 - 第二个请求失败
                    self.interceptorManager.didFailRequest(request2, target: target2, error: error)
                    
                    isCompleted = true
                    completion(.failure(error))
                    cancellable1?.cancel()
                }
            }
            
            // 返回包含取消逻辑的任务包装器
            return ManagedTask {
                cancellable1?.cancel()
                cancellable2?.cancel()
                loadingTimer?.invalidate()
                if needsLoading {
                    DispatchQueue.main.async {
                        LoadingIndicatorManager.shared.hideLoading()
                    }
                }
            }
        }
        
        // 交给协程管理器管理
        return CoroutineManager.shared.runNetworkTask(task, completion: completion)
    }
}
