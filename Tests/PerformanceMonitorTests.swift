//
//  PerformanceMonitorTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class PerformanceMonitorTests: XCTestCase {
    
    func testPerformanceMonitorConfiguration() {
        let monitor = PerformanceMonitor.shared
        
        // 测试默认配置
        let defaultConfig = monitor.getCurrentConfig()
        XCTAssertTrue(defaultConfig.enabled)
        XCTAssertEqual(defaultConfig.logLevel, .info)
        
        // 测试配置更新
        var newConfig = PerformanceMonitorConfig()
        newConfig.enabled = false
        newConfig.logLevel = .none
        newConfig.performanceThreshold = 5000
        monitor.configure(with: newConfig)
        
        let updatedConfig = monitor.getCurrentConfig()
        XCTAssertFalse(updatedConfig.enabled)
        XCTAssertEqual(updatedConfig.logLevel, .none)
        XCTAssertEqual(updatedConfig.performanceThreshold, 5000)
    }
    
    func testPerformanceMetrics() {
        let monitor = PerformanceMonitor.shared
        
        let startTime = Date()
        
        // 测试开始监控
        let startTimeReturned = monitor.startMonitoring(
            requestId: "test123",
            url: "https://api.example.com/test",
            method: "GET"
        )
        
        XCTAssertEqual(startTime.timeIntervalSince1970, startTimeReturned.timeIntervalSince1970, accuracy: 1.0)
        
        // 等待一小段时间
        Thread.sleep(forTimeInterval: 0.1)
        
        // 测试结束监控
        monitor.endMonitoring(
            requestId: "test123",
            url: "https://api.example.com/test",
            method: "GET",
            startTime: startTime,
            dataSize: 1024
        )
        
        // 测试获取指标
        let metrics = monitor.getAllMetrics()
        XCTAssertFalse(metrics.isEmpty)
        
        let overThresholdMetrics = monitor.getOverThresholdMetrics()
        // 可能为空，取决于阈值设置
    }
    
    func testPerformanceStats() {
        let monitor = PerformanceMonitor.shared
        
        // 清除现有指标
        monitor.clearAllMetrics()
        
        let stats = monitor.getPerformanceStats()
        XCTAssertEqual(stats.totalRequests, 0)
        XCTAssertEqual(stats.overThresholdRequests, 0)
        XCTAssertEqual(stats.averageDuration, 0, accuracy: 0.001)
        XCTAssertEqual(stats.maxDuration, 0, accuracy: 0.001)
        XCTAssertEqual(stats.averageMemoryUsage, 0, accuracy: 0.001)
        XCTAssertEqual(stats.totalNetworkTraffic, 0, accuracy: 0.001)
    }
}