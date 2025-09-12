//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUpWithError() throws {
        // 创建测试用的网络配置
        let config = NetworkConfig(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
        networkManager = NetworkManager(config: config, isTest: true)
    }

    override func tearDownWithError() throws {
        networkManager = nil
    }

    func testNetworkConfigInitialization() throws {
        XCTAssertNotNil(networkManager)
        XCTAssertEqual(networkManager.config.baseURL, URL(string: "https://jsonplaceholder.typicode.com")!)
        XCTAssertEqual(networkManager.config.timeoutInterval, 10.0)
        XCTAssertEqual(networkManager.config.maxRetryCount, 2)
    }
    
    func testAPIRequestProtocolDefaultValues() throws {
        // 测试GetUsersRequest的默认值
        let request = GetUsersRequest()
        XCTAssertTrue(request.allowsWeakNetwork)
        XCTAssertNil(request.timeoutInterval)
        XCTAssertNil(request.retryCount)
        XCTAssertFalse(request.needsLoadingIndicator)  // 根据示例实现，这个应该是false
    }
    
    func testAPIRequestProtocolCustomValues() throws {
        // 测试GetUserRequest的自定义值
        let request = GetUserRequest(userId: 1)
        XCTAssertTrue(request.allowsWeakNetwork)
        XCTAssertEqual(request.timeoutInterval, 15.0)
        XCTAssertNil(request.retryCount)
        XCTAssertTrue(request.needsLoadingIndicator)  // 根据示例实现，这个应该是true
    }
    
    func testNetworkErrorEquatable() throws {
        // 测试NetworkError的相等性
        let error1 = NetworkError.networkUnreachable
        let error2 = NetworkError.networkUnreachable
        XCTAssertEqual(error1, error2)
        
        let error3 = NetworkError.httpError(code: 404)
        let error4 = NetworkError.httpError(code: 404)
        XCTAssertEqual(error3, error4)
        
        let error5 = NetworkError.httpError(code: 404)
        let error6 = NetworkError.httpError(code: 500)
        XCTAssertNotEqual(error5, error6)
    }
    
    func testResponseHandlerSharedInstance() throws {
        // 测试ResponseHandler单例
        let handler1 = ResponseHandler.shared
        let handler2 = ResponseHandler.shared
        XCTAssertTrue(handler1 === handler2)
    }
    
    func testCoroutineManagerSharedInstance() throws {
        // 测试CoroutineManager单例
        let manager1 = CoroutineManager.shared
        let manager2 = CoroutineManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func testLoadingIndicatorManagerSharedInstance() throws {
        // 测试LoadingIndicatorManager单例
        let manager1 = LoadingIndicatorManager.shared
        let manager2 = LoadingIndicatorManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func testReachabilityManagerSharedInstance() throws {
        // 测试ReachabilityManager单例
        let manager1 = ReachabilityManager.shared
        let manager2 = ReachabilityManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
}
