//
//  EnvironmentManagerTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class EnvironmentManagerTests: XCTestCase {
    
    func testEnvironmentManagerInitialization() {
        let manager = EnvironmentManager.shared
        
        // 测试默认配置
        let configs = manager.getAllConfigs()
        XCTAssertFalse(configs.isEmpty)
        
        // 测试默认环境
        let currentEnv = manager.getCurrentEnvironment()
        XCTAssertEqual(currentEnv, .development)
    }
    
    func testEnvironmentConfiguration() {
        let manager = EnvironmentManager.shared
        
        // 测试获取特定环境配置
        let devConfig = manager.getConfig(for: .development)
        XCTAssertNotNil(devConfig)
        XCTAssertEqual(devConfig?.type, .development)
        
        let prodConfig = manager.getConfig(for: .production)
        XCTAssertNotNil(prodConfig)
        XCTAssertEqual(prodConfig?.type, .production)
    }
    
    func testEnvironmentSwitching() {
        let manager = EnvironmentManager.shared
        
        // 测试环境切换
        manager.setCurrentEnvironment(.production)
        let currentEnv = manager.getCurrentEnvironment()
        XCTAssertEqual(currentEnv, .production)
        
        manager.setCurrentEnvironment(.development)
        let currentEnv2 = manager.getCurrentEnvironment()
        XCTAssertEqual(currentEnv2, .development)
    }
    
    func testCustomEnvironmentConfig() {
        let manager = EnvironmentManager.shared
        
        // 创建自定义配置
        guard let customURL = URL(string: "https://custom.api.example.com") else {
            XCTFail("无法创建自定义URL")
            return
        }
        
        let customConfig = EnvironmentConfig(
            type: .testing,
            baseURL: customURL,
            apiVersion: "v2",
            timeoutInterval: 25.0,
            enableLogging: true,
            logLevel: .debug,
            maxRetryCount: 5,
            enableCache: false,
            customConfig: ["custom": true]
        )
        
        // 添加自定义配置
        manager.addConfig(customConfig, for: .testing)
        
        // 验证自定义配置
        let retrievedConfig = manager.getConfig(for: .testing)
        XCTAssertNotNil(retrievedConfig)
        XCTAssertEqual(retrievedConfig?.baseURL, customURL)
        XCTAssertEqual(retrievedConfig?.apiVersion, "v2")
        XCTAssertEqual(retrievedConfig?.timeoutInterval, 25.0)
        XCTAssertEqual(retrievedConfig?.enableLogging, true)
        XCTAssertEqual(retrievedConfig?.maxRetryCount, 5)
        XCTAssertEqual(retrievedConfig?.enableCache, false)
        XCTAssertEqual(retrievedConfig?.customConfig["custom"] as? Bool, true)
    }
}