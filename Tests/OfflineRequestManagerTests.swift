//
//  OfflineRequestManagerTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class OfflineRequestManagerTests: XCTestCase {
    
    func testOfflineRequestManagerInitialization() {
        let manager = OfflineRequestManager.shared
        
        // 测试初始化
        XCTAssertNotNil(manager)
    }
    
    func testOfflineRequestCRUD() {
        let manager = OfflineRequestManager.shared
        
        // 清除现有请求
        manager.clearAllRequests()
        
        // 测试添加请求
        let testData = "test data".data(using: .utf8)!
        let request = OfflineRequest(
            requestData: testData,
            status: .pending,
            targetEnvironment: .development
        )
        
        manager.addRequest(request)
        
        // 测试获取所有请求
        let allRequests = manager.getAllRequests()
        XCTAssertEqual(allRequests.count, 1)
        
        let pendingRequests = manager.getPendingRequests()
        XCTAssertEqual(pendingRequests.count, 1)
        
        // 测试更新请求状态
        manager.updateRequestStatus(request.id, to: .completed)
        
        let updatedRequests = manager.getAllRequests()
        XCTAssertEqual(updatedRequests.count, 1)
        XCTAssertEqual(updatedRequests[0].status, .completed)
        
        // 测试删除已完成的请求
        manager.removeCompletedRequests()
        
        let remainingRequests = manager.getAllRequests()
        XCTAssertTrue(remainingRequests.isEmpty)
    }
    
    func testOfflineRequestStats() {
        let manager = OfflineRequestManager.shared
        
        // 清除现有请求
        manager.clearAllRequests()
        
        // 添加不同状态的请求
        let testData = "test data".data(using: .utf8)!
        
        let pendingRequest = OfflineRequest(
            id: "pending1",
            requestData: testData,
            status: .pending,
            targetEnvironment: .development
        )
        
        let completedRequest = OfflineRequest(
            id: "completed1",
            requestData: testData,
            status: .completed,
            targetEnvironment: .development
        )
        
        let failedRequest = OfflineRequest(
            id: "failed1",
            requestData: testData,
            status: .failed,
            targetEnvironment: .development
        )
        
        manager.addRequest(pendingRequest)
        manager.addRequest(completedRequest)
        manager.addRequest(failedRequest)
        
        // 测试统计信息
        let stats = manager.getStats()
        XCTAssertEqual(stats.total, 3)
        XCTAssertEqual(stats.pending, 1)
        XCTAssertEqual(stats.completed, 1)
        XCTAssertEqual(stats.failed, 1)
    }
    
    func testOfflineRequestRetryCount() {
        let manager = OfflineRequestManager.shared
        
        // 清除现有请求
        manager.clearAllRequests()
        
        // 添加一个请求并多次更新状态为失败
        let testData = "test data".data(using: .utf8)!
        let requestId = "retry-test"
        
        let request = OfflineRequest(
            id: requestId,
            requestData: testData,
            status: .pending,
            targetEnvironment: .development
        )
        
        manager.addRequest(request)
        
        // 多次失败更新
        manager.updateRequestStatus(requestId, to: .failed)
        manager.updateRequestStatus(requestId, to: .pending)
        manager.updateRequestStatus(requestId, to: .failed)
        manager.updateRequestStatus(requestId, to: .pending)
        manager.updateRequestStatus(requestId, to: .failed)
        
        // 验证重试次数
        let requests = manager.getAllRequests()
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests[0].retryCount, 3)
    }
}