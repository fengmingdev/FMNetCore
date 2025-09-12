//
//  DynamicBaseURLTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking
import Moya

class DynamicBaseURLTests: XCTestCase {
    
    override func setUpWithError() throws {
        // 每个测试前清空动态Base URL
        DynamicBaseURLManager.shared.clearAllDynamicBaseURLs()
    }
    
    func testDynamicBaseURLManagerSetAndGet() {
        // 测试设置和获取动态Base URL
        let key = "testAPI"
        let url = URL(string: "https://custom-api.example.com")!
        
        DynamicBaseURLManager.shared.setDynamicBaseURL(url, for: key)
        let retrievedURL = DynamicBaseURLManager.shared.getDynamicBaseURL(for: key)
        
        XCTAssertNotNil(retrievedURL)
        XCTAssertEqual(retrievedURL, url)
    }
    
    func testDynamicBaseURLManagerRemove() {
        // 测试移除动态Base URL
        let key = "testAPI"
        let url = URL(string: "https://custom-api.example.com")!
        
        DynamicBaseURLManager.shared.setDynamicBaseURL(url, for: key)
        XCTAssertNotNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key))
        
        DynamicBaseURLManager.shared.removeDynamicBaseURL(for: key)
        XCTAssertNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key))
    }
    
    func testDynamicBaseURLManagerClearAll() {
        // 测试清空所有动态Base URL
        let key1 = "testAPI1"
        let key2 = "testAPI2"
        let url1 = URL(string: "https://custom-api1.example.com")!
        let url2 = URL(string: "https://custom-api2.example.com")!
        
        DynamicBaseURLManager.shared.setDynamicBaseURL(url1, for: key1)
        DynamicBaseURLManager.shared.setDynamicBaseURL(url2, for: key2)
        
        XCTAssertNotNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key1))
        XCTAssertNotNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key2))
        
        DynamicBaseURLManager.shared.clearAllDynamicBaseURLs()
        
        XCTAssertNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key1))
        XCTAssertNil(DynamicBaseURLManager.shared.getDynamicBaseURL(for: key2))
    }
    
    func testDynamicBaseURLTargetType() {
        // 测试DynamicBaseURLTargetType协议
        struct TestTarget: DynamicBaseURLTargetType {
            var dynamicBaseURL: URL? {
                return DynamicBaseURLManager.shared.getDynamicBaseURL(for: "test")
            }
            
            var defaultBaseURL: URL {
                return URL(string: "https://default.example.com")!
            }
            
            var path: String { return "/test" }
            var method: Moya.Method { return .get }
            var task: Task { return .requestPlain }
            var headers: [String: String]? { return nil }
        }
        
        let target = TestTarget()
        
        // 测试默认URL
        XCTAssertEqual(target.baseURL, URL(string: "https://default.example.com")!)
        
        // 测试动态URL
        let dynamicURL = URL(string: "https://dynamic.example.com")!
        DynamicBaseURLManager.shared.setDynamicBaseURL(dynamicURL, for: "test")
        XCTAssertEqual(target.baseURL, dynamicURL)
    }
}