//
//  OfflineRequestManager.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
import SystemConfiguration
import Combine

// 简化版的离线环境配置
public struct OfflineEnvironmentConfig: Codable {
    public let type: EnvironmentType
    public let baseURL: String  // 存储为字符串，避免URL类型的问题
    
    public init(type: EnvironmentType, baseURL: String) {
        self.type = type
        self.baseURL = baseURL
    }
}

/// 离线请求状态
public enum OfflineRequestStatus: String, Codable {
    case pending = "pending"
    case syncing = "syncing"
    case completed = "completed"
    case failed = "failed"
}

/// 离线请求
public struct OfflineRequest: Codable {
    /// 请求ID
    public let id: String
    
    /// 请求数据
    public let requestData: Data
    
    /// 请求时间
    public let timestamp: Date
    
    /// 状态
    public var status: OfflineRequestStatus
    
    /// 重试次数
    public var retryCount: Int
    
    /// 错误信息
    public var errorMessage: String?
    
    /// 目标环境配置
    public let targetEnvironment: OfflineEnvironmentConfig
    
    public init(
        id: String = UUID().uuidString,
        requestData: Data,
        timestamp: Date = Date(),
        status: OfflineRequestStatus = .pending,
        retryCount: Int = 0,
        errorMessage: String? = nil,
        targetEnvironment: OfflineEnvironmentConfig = OfflineEnvironmentConfig(type: .development, baseURL: "https://api.example.com")
    ) {
        self.id = id
        self.requestData = requestData
        self.timestamp = timestamp
        self.status = status
        self.retryCount = retryCount
        self.errorMessage = errorMessage
        self.targetEnvironment = targetEnvironment
    }
}

/// 离线请求管理器
public final class OfflineRequestManager {
    public static let shared = OfflineRequestManager()
    
    private var requests: [OfflineRequest] = []
    private let queue = DispatchQueue(label: "com.fmnetcore.offline", qos: .utility)
    private let fileManager = FileManager.default
    private let storageURL: URL
    private var isSyncing = false
    
    private init() {
        // 创建存储URL
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        storageURL = documentsDirectory.appendingPathComponent("offline_requests.json")
        
        // 加载已保存的离线请求
        loadRequests()
        
        // 监听网络状态变化
        setupNetworkMonitoring()
    }
    
    /// 设置网络状态监听
    private func setupNetworkMonitoring() {
        // 监听网络状态变化，在网络恢复时自动同步离线请求
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NSNotification.Name("NetworkStatusChanged"),
            object: nil
        )
    }
    
    /// 网络状态变化处理
    @objc private func networkStatusChanged() {
        // 检查网络是否恢复
        // 暂时注释掉这行，因为我们可能没有直接访问ReachabilityManager
        // if case .wifi = ReachabilityManager.shared.networkStatus {
            // 网络恢复，开始同步离线请求
            syncOfflineRequests()
        // }
    }
    
    /// 添加离线请求
    /// - Parameter request: 离线请求
    public func addRequest(_ request: OfflineRequest) {
        queue.async { [weak self] in
            self?.requests.append(request)
            self?.saveRequests()
        }
    }
    
    /// 更新离线请求状态
    /// - Parameters:
    ///   - requestId: 请求ID
    ///   - status: 新状态
    ///   - errorMessage: 错误信息（可选）
    public func updateRequestStatus(
        _ requestId: String,
        to status: OfflineRequestStatus,
        errorMessage: String? = nil
    ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                self.requests[index].status = status
                self.requests[index].errorMessage = errorMessage
                
                if status == .failed {
                    self.requests[index].retryCount += 1
                }
                
                self.saveRequests()
            }
        }
    }
    
    /// 获取所有离线请求
    /// - Returns: 离线请求数组
    public func getAllRequests() -> [OfflineRequest] {
        return queue.sync { requests }
    }
    
    /// 获取待同步的离线请求
    /// - Returns: 待同步的离线请求数组
    public func getPendingRequests() -> [OfflineRequest] {
        return queue.sync {
            requests.filter { $0.status == .pending }
        }
    }
    
    /// 删除已完成的请求
    public func removeCompletedRequests() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.requests.removeAll { $0.status == .completed }
            self.saveRequests()
        }
    }
    
    /// 清除所有请求
    public func clearAllRequests() {
        queue.async { [weak self] in
            self?.requests.removeAll()
            self?.saveRequests()
        }
    }
    
    /// 同步离线请求
    public func syncOfflineRequests() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 避免重复同步
            guard !self.isSyncing else { return }
            
            self.isSyncing = true
            defer { self.isSyncing = false }
            
            let pendingRequests = self.getPendingRequests()
            
            // 按时间顺序处理请求
            for request in pendingRequests.sorted(by: { $0.timestamp < $1.timestamp }) {
                self.syncRequest(request)
            }
        }
    }
    
    /// 同步单个请求
    /// - Parameter request: 离线请求
    private func syncRequest(_ request: OfflineRequest) {
        // 更新请求状态为同步中
        updateRequestStatus(request.id, to: .syncing)
        
        // 检查目标环境是否匹配当前环境
        // 由于离线请求管理器独立于主网络管理器，我们简化环境检查逻辑
        // 在实际应用中，这里应该根据应用的当前环境状态来决定是否同步请求
        
        // 尝试发送请求
        // 注意：这里需要根据实际的请求数据重构请求
        // 为了示例，我们只是模拟发送过程
        simulateRequestSending(request) { [weak self] success, error in
            if success {
                // 同步成功
                self?.updateRequestStatus(request.id, to: .completed)
            } else {
                // 同步失败
                // 使用默认重试次数
                let maxRetries = 3
                if request.retryCount < maxRetries {
                    // 可以重试
                    self?.updateRequestStatus(request.id, to: .pending)
                } else {
                    // 达到最大重试次数，标记为失败
                    self?.updateRequestStatus(request.id, to: .failed, errorMessage: error)
                }
            }
        }
    }
    
    /// 模拟请求发送
    /// - Parameters:
    ///   - request: 离线请求
    ///   - completion: 完成回调
    private func simulateRequestSending(
        _ request: OfflineRequest,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 模拟80%的成功率
            let success = Int.random(in: 1...100) <= 80
            let error = success ? nil : "网络错误"
            
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    /// 保存请求到文件
    private func saveRequests() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try JSONEncoder().encode(self.requests)
                try data.write(to: self.storageURL)
            } catch {
                print("保存离线请求失败: \(error)")
            }
        }
    }
    
    /// 从文件加载请求
    private func loadRequests() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            guard self.fileManager.fileExists(atPath: self.storageURL.path) else { return }
            
            do {
                let data = try Data(contentsOf: self.storageURL)
                let requests = try JSONDecoder().decode([OfflineRequest].self, from: data)
                self.requests = requests
            } catch {
                print("加载离线请求失败: \(error)")
            }
        }
    }
    
    /// 获取统计信息
    /// - Returns: 离线请求统计信息
    public func getStats() -> OfflineRequestStats {
        return queue.sync {
            let total = requests.count
            let pending = requests.filter { $0.status == .pending }.count
            let syncing = requests.filter { $0.status == .syncing }.count
            let completed = requests.filter { $0.status == .completed }.count
            let failed = requests.filter { $0.status == .failed }.count
            
            return OfflineRequestStats(
                total: total,
                pending: pending,
                syncing: syncing,
                completed: completed,
                failed: failed
            )
        }
    }
}

/// 离线请求统计信息
public struct OfflineRequestStats {
    /// 总请求数
    public let total: Int
    
    /// 待处理请求数
    public let pending: Int
    
    /// 同步中请求数
    public let syncing: Int
    
    /// 已完成请求数
    public let completed: Int
    
    /// 失败请求数
    public let failed: Int
    
    public init(total: Int, pending: Int, syncing: Int, completed: Int, failed: Int) {
        self.total = total
        self.pending = pending
        self.syncing = syncing
        self.completed = completed
        self.failed = failed
    }
}
