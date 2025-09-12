//
//  NetworkManagerTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
import Combine
import Moya
@testable import Networking

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
}