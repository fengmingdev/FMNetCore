//
//  NetworkInterceptor.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// 网络请求拦截器协议
public protocol NetworkInterceptor: AnyObject {
    /// 请求即将发送时调用
    /// - Parameters:
    ///   - request: 即将发送的请求
    ///   - target: Moya TargetType
    func willSendRequest(_ request: Any, target: TargetType)
    
    /// 请求完成时调用（无论成功或失败）
    /// - Parameters:
    ///   - request: 已完成的请求
    ///   - target: Moya TargetType
    ///   - result: 请求结果
    func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Moya.Response, MoyaError>)
    
    /// 请求成功时调用
    /// - Parameters:
    ///   - request: 成功的请求
    ///   - target: Moya TargetType
    ///   - response: 响应数据
    func didSucceedRequest(_ request: Any, target: TargetType, response: Moya.Response)
    
    /// 请求失败时调用
    /// - Parameters:
    ///   - request: 失败的请求
    ///   - target: Moya TargetType
    ///   - error: 错误信息
    func didFailRequest(_ request: Any, target: TargetType, error: MoyaError)
}

/// 默认的网络拦截器实现
open class DefaultNetworkInterceptor: NetworkInterceptor {
    public init() {}
    
    open func willSendRequest(_ request: Any, target: TargetType) {
        NetworkLogger.shared.log(.info, message: "🚀 发送请求: \(target.method) \(target.baseURL)\(target.path)")
    }
    
    open func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Moya.Response, MoyaError>) {
        switch result {
        case .success(let response):
            NetworkLogger.shared.log(.info, message: "✅ 请求完成: \(target.method) \(target.baseURL)\(target.path) - 状态码: \(response.statusCode)")
        case .failure(let error):
            NetworkLogger.shared.log(.error, message: "❌ 请求完成（失败）: \(target.method) \(target.baseURL)\(target.path) - 错误: \(error)")
        }
    }
    
    open func didSucceedRequest(_ request: Any, target: TargetType, response: Moya.Response) {
        NetworkLogger.shared.log(.info, message: "✅ 请求成功: \(target.method) \(target.baseURL)\(target.path) - 状态码: \(response.statusCode)")
    }
    
    open func didFailRequest(_ request: Any, target: TargetType, error: MoyaError) {
        NetworkLogger.shared.log(.error, message: "❌ 请求失败: \(target.method) \(target.baseURL)\(target.path) - 错误: \(error)")
    }
}

/// 网络拦截器管理器
public class NetworkInterceptorManager {
    /// 单例实例
    public static let shared = NetworkInterceptorManager()
    
    /// 拦截器列表
    private var interceptors: [NetworkInterceptor] = []
    
    /// 私有初始化方法
    private init() {}
    
    /// 用于测试的公共初始化方法
    /// - Returns: NetworkInterceptorManager实例
    internal init(forTesting: Bool) {
        // 这个初始化方法仅用于测试目的
    }
    
    /// 添加拦截器
    /// - Parameter interceptor: 要添加的拦截器
    public func addInterceptor(_ interceptor: NetworkInterceptor) {
        interceptors.append(interceptor)
    }
    
    /// 移除拦截器
    /// - Parameter interceptor: 要移除的拦截器
    public func removeInterceptor(_ interceptor: NetworkInterceptor) {
        // 使用对象标识来移除拦截器
        interceptors.removeAll { existingInterceptor in
            ObjectIdentifier(existingInterceptor) == ObjectIdentifier(interceptor)
        }
    }
    
    /// 移除所有拦截器
    public func removeAllInterceptors() {
        interceptors.removeAll()
    }
    
    /// 请求即将发送
    /// - Parameters:
    ///   - request: 请求对象
    ///   - target: TargetType目标
    func willSendRequest(_ request: any APIRequest, target: TargetType) {
        for interceptor in interceptors {
            interceptor.willSendRequest(request, target: target)
        }
    }
    
    /// 请求完成
    /// - Parameters:
    ///   - request: 请求对象
    ///   - target: TargetType目标
    ///   - result: 请求结果
    func didCompleteRequest(_ request: any APIRequest, target: TargetType, result: Result<Response, MoyaError>) {
        for interceptor in interceptors {
            interceptor.didCompleteRequest(request, target: target, result: result)
        }
    }
    
    /// 请求成功
    /// - Parameters:
    ///   - request: 请求对象
    ///   - target: TargetType目标
    ///   - response: 响应对象
    func didSucceedRequest(_ request: any APIRequest, target: TargetType, response: Response) {
        for interceptor in interceptors {
            interceptor.didSucceedRequest(request, target: target, response: response)
        }
    }
    
    /// 请求失败
    /// - Parameters:
    ///   - request: 请求对象
    ///   - target: TargetType目标
    ///   - error: 错误对象
    func didFailRequest(_ request: any APIRequest, target: TargetType, error: Error) {
        // 将Error转换为MoyaError（如果可能）
        let moyaError: MoyaError
        if let error = error as? MoyaError {
            moyaError = error
        } else {
            // 如果不是MoyaError，创建一个包装错误
            moyaError = MoyaError.underlying(error, nil)
        }
        
        for interceptor in interceptors {
            interceptor.didFailRequest(request, target: target, error: moyaError)
        }
    }
}

/// 日志拦截器
open class LoggingInterceptor: NetworkInterceptor {
    public init() {}
    
    open func willSendRequest(_ request: Any, target: TargetType) {
        NetworkLogger.shared.log(.info, message: "📡 [请求发送] \(target.method) \(target.baseURL)\(target.path)")
        if let apiRequest = request as? any APIRequest {
            NetworkLogger.shared.log(.info, message: "   请求对象: \(type(of: apiRequest))")
        }
    }
    
    open func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Moya.Response, MoyaError>) {
        switch result {
        case .success(let response):
            NetworkLogger.shared.log(.info, message: "✅ [请求完成] \(target.method) \(target.baseURL)\(target.path) - 状态码: \(response.statusCode)")
        case .failure(let error):
            NetworkLogger.shared.log(.error, message: "❌ [请求完成] \(target.method) \(target.baseURL)\(target.path) - 错误: \(error)")
        }
    }
    
    open func didSucceedRequest(_ request: Any, target: TargetType, response: Moya.Response) {
        NetworkLogger.shared.log(.info, message: "✅ [请求成功] \(target.method) \(target.baseURL)\(target.path) - 状态码: \(response.statusCode)")
    }
    
    open func didFailRequest(_ request: Any, target: TargetType, error: MoyaError) {
        NetworkLogger.shared.log(.error, message: "❌ [请求失败] \(target.method) \(target.baseURL)\(target.path) - 错误: \(error)")
    }
}

/// 性能监控拦截器
open class PerformanceInterceptor: NetworkInterceptor {
    private var requestStartTimes: [String: Date] = [:]
    
    public init() {}
    
    open func willSendRequest(_ request: Any, target: TargetType) {
        let key = "\(target.method.rawValue)\(target.baseURL)\(target.path)"
        requestStartTimes[key] = Date()
    }
    
    open func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Moya.Response, MoyaError>) {
        let key = "\(target.method.rawValue)\(target.baseURL)\(target.path)"
        if let startTime = requestStartTimes[key] {
            let duration = Date().timeIntervalSince(startTime)
            NetworkLogger.shared.log(.info, message: "⏱ [性能监控] \(target.method) \(target.baseURL)\(target.path) - 耗时: \(String(format: "%.2f", duration * 1000))ms")
            requestStartTimes.removeValue(forKey: key)
        }
    }
    
    open func didSucceedRequest(_ request: Any, target: TargetType, response: Moya.Response) {
        // 性能监控在didCompleteRequest中处理
    }
    
    open func didFailRequest(_ request: Any, target: TargetType, error: MoyaError) {
        // 性能监控在didCompleteRequest中处理
    }
}

/// 缓存拦截器
open class CacheInterceptor: NetworkInterceptor {
    public init() {}
    
    open func willSendRequest(_ request: Any, target: TargetType) {
        // 请求发送前的处理
    }
    
    open func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Response, MoyaError>) {
        // 请求完成后的处理
    }
    
    open func didSucceedRequest(_ request: Any, target: TargetType, response: Response) {
        // 请求成功后的处理
    }
    
    open func didFailRequest(_ request: Any, target: TargetType, error: MoyaError) {
        // 请求失败后的处理
    }
}