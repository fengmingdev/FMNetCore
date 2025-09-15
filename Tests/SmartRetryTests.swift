//
//  SmartRetryTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class SmartRetryTests: XCTestCase {
    
    func testExponentialBackoffRetryStrategy() {
        let strategy = ExponentialBackoffRetryStrategy(baseDelay: 1.0, maxDelay: 60.0, multiplier: 2.0)
        
        // 测试延迟计算
        XCTAssertEqual(strategy.calculateRetryDelay(for: 0, with: .timeout), 1.0)
        XCTAssertEqual(strategy.calculateRetryDelay(for: 1, with: .timeout), 2.0)
        XCTAssertEqual(strategy.calculateRetryDelay(for: 2, with: .timeout), 4.0)
        XCTAssertEqual(strategy.calculateRetryDelay(for: 3, with: .timeout), 8.0)
        
        // 测试最大延迟限制
        let largeAttemptDelay = strategy.calculateRetryDelay(for: 10, with: .timeout)
        XCTAssertLessThanOrEqual(largeAttemptDelay, 60.0)
        
        // 测试重试决策
        XCTAssertTrue(strategy.shouldRetry(for: 0, maxRetries: 3, with: .timeout))
        XCTAssertTrue(strategy.shouldRetry(for: 1, maxRetries: 3, with: .timeout))
        XCTAssertTrue(strategy.shouldRetry(for: 2, maxRetries: 3, with: .timeout))
        XCTAssertFalse(strategy.shouldRetry(for: 3, maxRetries: 3, with: .timeout))
        
        // 测试不同错误类型的重试决策
        XCTAssertTrue(strategy.shouldRetry(for: 0, maxRetries: 3, with: .timeout))
        XCTAssertTrue(strategy.shouldRetry(for: 0, maxRetries: 3, with: .networkUnreachable))
        XCTAssertTrue(strategy.shouldRetry(for: 0, maxRetries: 3, with: .serverError(500)))
        XCTAssertFalse(strategy.shouldRetry(for: 0, maxRetries: 3, with: .httpError(code: 404)))
    }
    
    func testAdaptiveRetryStrategy() {
        let strategy = AdaptiveRetryStrategy()
        
        // 测试延迟计算
        let delay = strategy.calculateRetryDelay(for: 0, with: .timeout)
        XCTAssertTrue(delay >= 1.0)
        
        // 测试重试决策
        let shouldRetry = strategy.shouldRetry(for: 0, maxRetries: 3, with: .timeout)
        XCTAssertTrue(shouldRetry)
    }
    
    func testDefaultErrorRecoveryStrategy() {
        let strategy = DefaultErrorRecoveryStrategy()
        
        // 测试超时错误恢复
        let timeoutResult = strategy.recover(from: .timeout, attempt: 0)
        XCTAssertNil(timeoutResult)
        
        let timeoutResult2 = strategy.recover(from: .timeout, attempt: 1)
        XCTAssertNotNil(timeoutResult2)
        
        // 测试网络不可达错误恢复
        let networkResult = strategy.recover(from: .networkUnreachable, attempt: 0)
        XCTAssertNil(networkResult)
        
        let networkResult2 = strategy.recover(from: .networkUnreachable, attempt: 1)
        XCTAssertNotNil(networkResult2)
    }
}