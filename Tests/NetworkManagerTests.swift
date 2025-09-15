//
//  NetworkManagerTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
import Combine
import Moya
@testable import FMNetCore

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        let config = NetworkConfig(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
        networkManager = NetworkManager(config: config, isTest: true)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        networkManager = nil
        cancellables = nil
    }
    
    func testNetworkManagerSharedInstance() throws {
        let manager1 = NetworkManager.shared
        let manager2 = NetworkManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func testNetworkManagerInitialization() throws {
        XCTAssertNotNil(networkManager)
        XCTAssertNotNil(networkManager.provider)
        XCTAssertEqual(networkManager.cancellables.count, 0)
    }
    
    func testCacheManagerSharedInstance() throws {
        let cacheManager1 = CacheManager.shared
        let cacheManager2 = CacheManager.shared
        XCTAssertTrue(cacheManager1 === cacheManager2)
    }
    
    func testCacheConfigDefaultValues() throws {
        let config = CacheConfig()
        XCTAssertEqual(config.maxDiskCacheSize, 50 * 1024 * 1024)
        XCTAssertEqual(config.defaultMemoryExpiry, 300)
        XCTAssertEqual(config.defaultDiskExpiry, 3600)
    }
    
    func testCombinedRequestTwoRequests() throws {
        // 创建测试用的请求
        let request1 = GetUsersRequest()
        let request2 = GetPostsRequest()
        
        let expectation = self.expectation(description: "Combined request should complete")
        
        var result: Result<(User, Post), Error>?
        
        // 使用协程方式测试组合请求
        let taskId = networkManager.combinedRequest(request1, request2) { (combinedResult: Result<(User, Post), Error>) in
            result = combinedResult
            expectation.fulfill()
        }
        
        // 添加一个小延迟以确保请求有时间执行
        let timeoutResult = XCTWaiter.wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(timeoutResult, .completed)
        
        // 取消任务（如果需要）
        CoroutineManager.shared.cancelTask(taskId)
    }
    
    func testSingleRequestWithLoading() throws {
        let request = GetUserRequest(userId: 1)
        
        let expectation = self.expectation(description: "Single request with loading should complete")
        
        var result: Result<User, Error>?
        
        let taskId = networkManager.requestWithLoading(request) { (requestResult: Result<User, Error>) in
            result = requestResult
            expectation.fulfill()
        }
        
        let timeoutResult = XCTWaiter.wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(timeoutResult, .completed)
        
        CoroutineManager.shared.cancelTask(taskId)
    }
    
    func testNetworkConfigDefaultValues() throws {
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        XCTAssertEqual(config.timeoutInterval, 10.0)
        XCTAssertEqual(config.enableLogging, false)
        XCTAssertEqual(config.maxRetryCount, 2)
        XCTAssertEqual(config.retryInterval, 1.0)
        XCTAssertEqual(config.slowNetworkThreshold, 3.0)
        XCTAssertEqual(config.headers.count, 0)
    }
    
    func testNetworkConfigCustomValues() throws {
        var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        config.timeoutInterval = 20.0
        config.enableLogging = true
        config.maxRetryCount = 5
        config.retryInterval = 2.0
        config.slowNetworkThreshold = 5.0
        config.headers = ["Authorization": "Bearer token"]
        
        XCTAssertEqual(config.timeoutInterval, 20.0)
        XCTAssertEqual(config.enableLogging, true)
        XCTAssertEqual(config.maxRetryCount, 5)
        XCTAssertEqual(config.retryInterval, 2.0)
        XCTAssertEqual(config.slowNetworkThreshold, 5.0)
        XCTAssertEqual(config.headers["Authorization"], "Bearer token")
    }
    
    // 新增的测试用例
    
    func testSmartRetryStrategy() throws {
        let strategy = AdaptiveRetryStrategy()
        
        // 测试重试延迟计算
        let delay = strategy.calculateRetryDelay(for: 0, with: .timeout)
        XCTAssertTrue(delay >= 1.0)
        
        // 测试是否应该重试
        let shouldRetry = strategy.shouldRetry(for: 0, maxRetries: 3, with: .timeout)
        XCTAssertTrue(shouldRetry)
    }
    
    func testPerformanceMonitor() throws {
        let monitor = PerformanceMonitor.shared
        
        // 测试配置
        var config = PerformanceMonitorConfig()
        config.enabled = true
        config.performanceThreshold = 1000
        monitor.configure(with: config)
        
        let currentConfig = monitor.getCurrentConfig()
        XCTAssertEqual(currentConfig.enabled, true)
        XCTAssertEqual(currentConfig.performanceThreshold, 1000)
    }
    
    func testEnvironmentManager() throws {
        let manager = EnvironmentManager.shared
        
        // 测试获取当前环境
        let currentEnv = manager.getCurrentEnvironment()
        XCTAssertNotNil(currentEnv)
        
        // 测试获取所有配置
        let configs = manager.getAllConfigs()
        XCTAssertFalse(configs.isEmpty)
    }
    
    func testLocalizationManager() throws {
        let manager = LocalizationManager.shared
        
        // 测试获取当前语言
        let languageCode = manager.currentLanguageCode()
        XCTAssertFalse(languageCode.isEmpty)
        
        // 测试本地化字符串
        let localizedString = manager.localizedString(for: "network.error.invalid_url", defaultValue: "Invalid URL")
        XCTAssertFalse(localizedString.isEmpty)
    }
    
    func testVersionManager() throws {
        let manager = VersionManager.shared
        
        // 测试设置和获取当前API版本
        manager.setCurrentAPIVersion(.v2)
        let currentVersion = manager.getCurrentAPIVersion()
        XCTAssertEqual(currentVersion, .v2)
        
        // 测试兼容性策略
        manager.setCompatibilityStrategy(.strict)
        let strategy = manager.getCompatibilityStrategy()
        XCTAssertEqual(strategy, .strict)
    }
}