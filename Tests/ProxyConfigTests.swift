//
//  ProxyConfigTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking

class ProxyConfigTests: XCTestCase {
    
    func testProxyConfigInitialization() {
        // 测试基本初始化
        let proxyConfig = ProxyConfig(host: "127.0.0.1", port: 8080)
        
        XCTAssertEqual(proxyConfig.host, "127.0.0.1")
        XCTAssertEqual(proxyConfig.port, 8080)
        XCTAssertTrue(proxyConfig.httpEnabled)
        XCTAssertTrue(proxyConfig.httpsEnabled)
        XCTAssertNil(proxyConfig.username)
        XCTAssertNil(proxyConfig.password)
    }
    
    func testProxyConfigWithAuth() {
        // 测试带认证信息的初始化
        let proxyConfig = ProxyConfig(
            host: "proxy.example.com",
            port: 3128,
            httpEnabled: true,
            httpsEnabled: false,
            username: "user",
            password: "pass"
        )
        
        XCTAssertEqual(proxyConfig.host, "proxy.example.com")
        XCTAssertEqual(proxyConfig.port, 3128)
        XCTAssertTrue(proxyConfig.httpEnabled)
        XCTAssertFalse(proxyConfig.httpsEnabled)
        XCTAssertEqual(proxyConfig.username, "user")
        XCTAssertEqual(proxyConfig.password, "pass")
    }
    
    func testNetworkConfigWithProxy() {
        // 测试NetworkConfig中的代理配置
        var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        XCTAssertNil(config.proxyConfig)
        
        let proxyConfig = ProxyConfig(host: "127.0.0.1", port: 8080)
        config.proxyConfig = proxyConfig
        
        XCTAssertNotNil(config.proxyConfig)
        XCTAssertEqual(config.proxyConfig?.host, "127.0.0.1")
        XCTAssertEqual(config.proxyConfig?.port, 8080)
    }
}