//
//  SmartRetryStrategy.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
import Combine

/// 重试策略协议
public protocol RetryStrategy {
    /// 计算重试延迟时间
    /// - Parameters:
    ///   - attempt: 当前重试次数
    ///   - error: 导致重试的错误
    /// - Returns: 延迟时间（秒）
    func calculateRetryDelay(for attempt: Int, with error: NetworkError) -> TimeInterval
    
    /// 判断是否应该重试
    /// - Parameters:
    ///   - attempt: 当前重试次数
    ///   - maxRetries: 最大重试次数
    ///   - error: 导致重试的错误
    /// - Returns: 是否应该重试
    func shouldRetry(for attempt: Int, maxRetries: Int, with error: NetworkError) -> Bool
}

/// 指数退避重试策略
public class ExponentialBackoffRetryStrategy: RetryStrategy {
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let multiplier: Double
    
    public init(baseDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 60.0, multiplier: Double = 2.0) {
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.multiplier = multiplier
    }
    
    public func calculateRetryDelay(for attempt: Int, with error: NetworkError) -> TimeInterval {
        // 计算指数退避延迟: baseDelay * (multiplier ^ attempt)
        let delay = baseDelay * pow(multiplier, Double(attempt))
        return min(delay, maxDelay)
    }
    
    public func shouldRetry(for attempt: Int, maxRetries: Int, with error: NetworkError) -> Bool {
        // 如果已达到最大重试次数，不重试
        guard attempt < maxRetries else { return false }
        
        // 根据错误类型决定是否重试
        switch error {
        case .timeout, .networkUnreachable, .weakNetwork:
            // 网络相关错误可以重试
            return true
        case .serverError(let code) where code >= 500:
            // 5xx服务器错误可以重试
            return true
        case .httpError(let code) where code >= 500:
            // 5xx HTTP错误可以重试
            return true
        default:
            // 其他错误不重试
            return false
        }
    }
}

/// 自适应重试策略
public class AdaptiveRetryStrategy: RetryStrategy {
    private let exponentialStrategy: ExponentialBackoffRetryStrategy
    private let networkStatusProvider: () -> NetworkStatus
    
    public init(
        exponentialStrategy: ExponentialBackoffRetryStrategy = ExponentialBackoffRetryStrategy(),
        networkStatusProvider: @escaping () -> NetworkStatus = { ReachabilityManager.shared.networkStatus }
    ) {
        self.exponentialStrategy = exponentialStrategy
        self.networkStatusProvider = networkStatusProvider
    }
    
    public func calculateRetryDelay(for attempt: Int, with error: NetworkError) -> TimeInterval {
        var delay = exponentialStrategy.calculateRetryDelay(for: attempt, with: error)
        
        // 根据网络状态调整延迟
        let networkStatus = networkStatusProvider()
        switch networkStatus {
        case .cellular(let quality):
            switch quality {
            case .poor:
                // 弱网环境下增加延迟
                delay *= 2.0
            case .fair:
                // 一般网络环境下适度增加延迟
                delay *= 1.5
            default:
                break
            }
        default:
            break
        }
        
        return delay
    }
    
    public func shouldRetry(for attempt: Int, maxRetries: Int, with error: NetworkError) -> Bool {
        // 首先使用指数退避策略判断
        guard exponentialStrategy.shouldRetry(for: attempt, maxRetries: maxRetries, with: error) else {
            return false
        }
        
        // 根据网络状态进一步判断
        let networkStatus = networkStatusProvider()
        switch networkStatus {
        case .unreachable:
            // 网络不可达时不重试
            return false
        case .cellular(let quality) where quality == .poor:
            // 弱网环境下限制重试次数
            return attempt < min(maxRetries, 2)
        default:
            return true
        }
    }
}

/// 错误恢复策略协议
public protocol ErrorRecoveryStrategy {
    /// 尝试从错误中恢复
    /// - Parameters:
    ///   - error: 原始错误
    ///   - attempt: 当前重试次数
    /// - Returns: 恢复后的错误或nil（表示可以继续重试）
    func recover(from error: NetworkError, attempt: Int) -> NetworkError?
}

/// 默认错误恢复策略
public class DefaultErrorRecoveryStrategy: ErrorRecoveryStrategy {
    public init() {}
    
    public func recover(from error: NetworkError, attempt: Int) -> NetworkError? {
        // 对于某些错误，可以尝试恢复
        switch error {
        case .timeout:
            // 超时错误可以尝试降低超时时间
            if attempt > 1 {
                // 第二次及以后的重试，返回原始错误表示可以继续重试
                return nil
            }
            return error
        case .networkUnreachable:
            // 网络不可达错误在短时间内重试可能无效
            if attempt > 0 {
                return error
            }
            return nil
        default:
            return error
        }
    }
}