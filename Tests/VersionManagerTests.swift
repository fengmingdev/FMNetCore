//
//  VersionManagerTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class VersionManagerTests: XCTestCase {
    
    func testVersionManagerInitialization() {
        let manager = VersionManager.shared
        
        // 测试初始化
        XCTAssertNotNil(manager)
        
        // 测试默认版本
        let currentVersion = manager.getCurrentAPIVersion()
        XCTAssertEqual(currentVersion, .v1)
    }
    
    func testVersionConfiguration() {
        let manager = VersionManager.shared
        
        // 测试设置和获取当前版本
        manager.setCurrentAPIVersion(.v2)
        let currentVersion = manager.getCurrentAPIVersion()
        XCTAssertEqual(currentVersion, .v2)
        
        manager.setCurrentAPIVersion(.v3)
        let currentVersion2 = manager.getCurrentAPIVersion()
        XCTAssertEqual(currentVersion2, .v3)
    }
    
    func testCompatibilityStrategy() {
        let manager = VersionManager.shared
        
        // 测试设置和获取兼容性策略
        manager.setCompatibilityStrategy(.strict)
        let strategy = manager.getCompatibilityStrategy()
        XCTAssertEqual(strategy, .strict)
        
        manager.setCompatibilityStrategy(.lenient)
        let strategy2 = manager.getCompatibilityStrategy()
        XCTAssertEqual(strategy2, .lenient)
        
        manager.setCompatibilityStrategy(.automatic)
        let strategy3 = manager.getCompatibilityStrategy()
        XCTAssertEqual(strategy3, .automatic)
    }
    
    func testAPIEndpointGeneration() {
        let manager = VersionManager.shared
        
        // 测试API端点生成
        let endpoint1 = manager.getAPIEndpoint(basePath: "https://api.example.com/")
        XCTAssertEqual(endpoint1, "https://api.example.com/v1")
        
        manager.setCurrentAPIVersion(.v2)
        let endpoint2 = manager.getAPIEndpoint(basePath: "https://api.example.com/")
        XCTAssertEqual(endpoint2, "https://api.example.com/v2")
        
        // 测试带版本参数的端点生成
        let endpoint3 = manager.getAPIEndpoint(basePath: "https://api.example.com/", version: .v3)
        XCTAssertEqual(endpoint3, "https://api.example.com/v3")
    }
    
    func testDeprecationManagement() {
        let manager = VersionManager.shared
        
        // 测试API废弃标记
        manager.deprecateAPI("getUser")
        XCTAssertTrue(manager.isAPI_DEPRECATED("getUser"))
        XCTAssertFalse(manager.isAPI_DEPRECATED("createUser"))
        
        // 测试版本废弃标记
        manager.deprecateVersion(.v1)
        XCTAssertTrue(manager.isVersion_DEPRECATED(.v1))
        XCTAssertFalse(manager.isVersion_DEPRECATED(.v2))
    }
    
    func testVersionCompatibilityReport() {
        let manager = VersionManager.shared
        
        // 设置一些测试数据
        manager.deprecateAPI("oldAPI")
        manager.deprecateVersion(.v1)
        manager.setCompatibilityStrategy(.lenient)
        manager.setCurrentAPIVersion(.v2)
        
        // 获取兼容性报告
        let report = manager.getCompatibilityReport()
        
        XCTAssertEqual(report.currentVersion, .v2)
        XCTAssertEqual(report.compatibilityStrategy, .lenient)
        XCTAssertTrue(report.deprecatedAPIs.contains("oldAPI"))
        XCTAssertTrue(report.deprecatedVersions.contains(.v1))
    }
    
    func testVersionAdjustment() {
        let manager = VersionManager.shared
        
        // 测试严格模式
        manager.setCompatibilityStrategy(.strict)
        let strictEndpoint = manager.getAPIEndpoint(basePath: "https://api.example.com/", version: .v1)
        XCTAssertEqual(strictEndpoint, "https://api.example.com/v1")
        
        // 测试自动模式
        manager.setCompatibilityStrategy(.automatic)
        let autoEndpoint = manager.getAPIEndpoint(basePath: "https://api.example.com/", version: .v1)
        XCTAssertEqual(autoEndpoint, "https://api.example.com/v1")
    }
}