//
//  ReachabilityManagerTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking

final class ReachabilityManagerTests: XCTestCase {
    
    func testNetworkStatusEquatable() throws {
        // 测试NetworkStatus的相等性
        let status1: NetworkStatus = .unknown
        let status2: NetworkStatus = .unknown
        XCTAssertEqual(status1, status2)
        
        let status3: NetworkStatus = .unreachable
        let status4: NetworkStatus = .unreachable
        XCTAssertEqual(status3, status4)
        
        let status5: NetworkStatus = .wifi
        let status6: NetworkStatus = .wifi
        XCTAssertEqual(status5, status6)
        
        let status7: NetworkStatus = .cellular(quality: .excellent)
        let status8: NetworkStatus = .cellular(quality: .excellent)
        XCTAssertEqual(status7, status8)
        
        let status9: NetworkStatus = .cellular(quality: .excellent)
        let status10: NetworkStatus = .cellular(quality: .good)
        XCTAssertNotEqual(status9, status10)
        
        let status11: NetworkStatus = .wifi
        let status12: NetworkStatus = .cellular(quality: .excellent)
        XCTAssertNotEqual(status11, status12)
    }
    
    func testNetworkQualityEquatable() throws {
        // 测试NetworkQuality的相等性
        let quality1: NetworkQuality = .excellent
        let quality2: NetworkQuality = .excellent
        XCTAssertEqual(quality1, quality2)
        
        let quality3: NetworkQuality = .good
        let quality4: NetworkQuality = .good
        XCTAssertEqual(quality3, quality4)
        
        let quality5: NetworkQuality = .excellent
        let quality6: NetworkQuality = .good
        XCTAssertNotEqual(quality5, quality6)
    }
    
    func testReachabilityManagerStartMonitoring() throws {
        let manager = ReachabilityManager.shared
        // 确保可以调用startMonitoring而不会崩溃
        manager.startMonitoring()
        // 可以添加更多具体的测试逻辑
    }
    
    func testReachabilityManagerStopMonitoring() throws {
        let manager = ReachabilityManager.shared
        // 确保可以调用stopMonitoring而不会崩溃
        manager.stopMonitoring()
        // 可以添加更多具体的测试逻辑
    }
}