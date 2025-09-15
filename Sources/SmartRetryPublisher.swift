//
//  SmartRetryPublisher.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
import Combine

extension Publisher {
    /// 智能重试操作符
    /// - Parameters:
    ///   - maxRetries: 最大重试次数
    ///   - strategy: 重试策略
    ///   - errorTransformer: 错误转换器，用于将原始错误转换为NetworkError
    /// - Returns: 重试后的Publisher
    public func smartRetry(
        maxRetries: Int,
        strategy: RetryStrategy,
        errorTransformer: @escaping (Failure) -> NetworkError?
    ) -> AnyPublisher<Output, Failure> where Failure == NetworkError {
        return SmartRetryPublisher(
            upstream: self,
            maxRetries: maxRetries,
            strategy: strategy,
            errorTransformer: errorTransformer
        ).eraseToAnyPublisher()
    }
}

/// 智能重试Publisher
private struct SmartRetryPublisher<Upstream: Publisher>: Publisher where Upstream.Failure == NetworkError {
    typealias Output = Upstream.Output
    typealias Failure = NetworkError
    
    private let upstream: Upstream
    private let maxRetries: Int
    private let strategy: RetryStrategy
    private let errorTransformer: (NetworkError) -> NetworkError?
    
    init(
        upstream: Upstream,
        maxRetries: Int,
        strategy: RetryStrategy,
        errorTransformer: @escaping (NetworkError) -> NetworkError?
    ) {
        self.upstream = upstream
        self.maxRetries = maxRetries
        self.strategy = strategy
        self.errorTransformer = errorTransformer
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = SmartRetrySubscription(
            subscriber: subscriber,
            upstream: upstream,
            maxRetries: maxRetries,
            strategy: strategy,
            errorTransformer: errorTransformer
        )
        subscriber.receive(subscription: subscription)
    }
}

/// 智能重试Subscription
private class SmartRetrySubscription<Upstream: Publisher, Downstream: Subscriber>: Subscription
where Upstream.Failure == NetworkError, Downstream.Failure == NetworkError, Upstream.Output == Downstream.Input {
    
    private var subscriber: Downstream?
    private let upstream: Upstream
    private let maxRetries: Int
    private let strategy: RetryStrategy
    private let errorTransformer: (NetworkError) -> NetworkError?
    
    private var currentRetry = 0
    private var upstreamSubscription: Subscription?
    private var downstreamDemand: Subscribers.Demand = .none
    
    init(
        subscriber: Downstream,
        upstream: Upstream,
        maxRetries: Int,
        strategy: RetryStrategy,
        errorTransformer: @escaping (NetworkError) -> NetworkError?
    ) {
        self.subscriber = subscriber
        self.upstream = upstream
        self.maxRetries = maxRetries
        self.strategy = strategy
        self.errorTransformer = errorTransformer
    }
    
    func request(_ demand: Subscribers.Demand) {
        downstreamDemand += demand
        if upstreamSubscription == nil {
            upstream.subscribe(self)
        }
    }
    
    func cancel() {
        upstreamSubscription?.cancel()
        upstreamSubscription = nil
        subscriber = nil
    }
}

extension SmartRetrySubscription: Subscriber {
    typealias Input = Upstream.Output
    typealias Failure = NetworkError
    
    func receive(subscription: Subscription) {
        upstreamSubscription = subscription
        if downstreamDemand > 0 {
            subscription.request(downstreamDemand)
        }
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        guard let subscriber = subscriber else { return .none }
        return subscriber.receive(input)
    }
    
    func receive(completion: Subscribers.Completion<NetworkError>) {
        switch completion {
        case .finished:
            subscriber?.receive(completion: .finished)
        case .failure(let error):
            handleFailure(error)
        }
    }
    
    private func handleFailure(_ error: NetworkError) {
        // 转换错误（如果需要）
        let transformedError = errorTransformer(error) ?? error
        
        // 检查是否应该重试
        if strategy.shouldRetry(for: currentRetry, maxRetries: maxRetries, with: transformedError) {
            // 计算重试延迟
            let delay = strategy.calculateRetryDelay(for: currentRetry, with: transformedError)
            
            // 增加重试计数
            currentRetry += 1
            
            // 延迟后重试
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                self.upstream.subscribe(self)
            }
        } else {
            // 不重试，传递错误给下游
            subscriber?.receive(completion: .failure(transformedError))
        }
    }
}
