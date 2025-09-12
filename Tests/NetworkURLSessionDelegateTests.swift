//
//  NetworkURLSessionDelegateTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking

class NetworkConfigTests: XCTestCase {
    
    func testNetworkConfigInitialization() {
        // 测试NetworkConfig初始化
        let config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        XCTAssertNotNil(config)
        XCTAssertEqual(config.baseURL, URL(string: "https://api.example.com")!)
    }
    
    func testNetworkConfigRedirectSettings() {
        // 测试NetworkConfig中的重定向设置
        var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        XCTAssertTrue(config.allowRedirects)
        XCTAssertEqual(config.maxRedirects, 10)
        
        config.allowRedirects = false
        config.maxRedirects = 5
        
        XCTAssertFalse(config.allowRedirects)
        XCTAssertEqual(config.maxRedirects, 5)
    }
    
    func testNetworkConfigCertificateSettings() {
        // 测试NetworkConfig中的证书设置
        var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        XCTAssertNil(config.sslCertificatePath)
        XCTAssertFalse(config.allowInvalidCertificates)
        
        config.sslCertificatePath = "/path/to/certificate.pem"
        config.allowInvalidCertificates = true
        
        XCTAssertEqual(config.sslCertificatePath, "/path/to/certificate.pem")
        XCTAssertTrue(config.allowInvalidCertificates)
    }
}