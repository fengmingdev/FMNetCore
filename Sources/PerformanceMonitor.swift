//
//  PerformanceMonitor.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation

/// 性能监控配置
public struct PerformanceMonitorConfig {
    /// 是否启用性能监控
    public var enabled: Bool = true
    
    /// 是否记录详细性能指标
    public var detailedMetrics: Bool = false
    
    /// 性能日志级别
    public var logLevel: PerformanceLogLevel = .info
    
    /// 性能阈值（毫秒）
    public var performanceThreshold: TimeInterval = 3000
    
    /// 是否启用内存使用监控
    public var enableMemoryMonitoring: Bool = false
    
    /// 内存使用阈值（MB）
    public var memoryThreshold: Double = 100
    
    /// 是否启用网络流量监控
    public var enableNetworkTrafficMonitoring: Bool = false
    
    /// 网络流量阈值（MB）
    public var networkTrafficThreshold: Double = 10
    
    public init() {}
}

/// 性能日志级别
public enum PerformanceLogLevel: Int, CaseIterable {
    case verbose = 0
    case info = 1
    case warning = 2
    case error = 3
    case none = 4
}

/// 性能指标
public struct PerformanceMetrics {
    /// 请求ID
    public let requestId: String
    
    /// 请求URL
    public let url: String
    
    /// HTTP方法
    public let method: String
    
    /// 请求开始时间
    public let startTime: Date
    
    /// 请求结束时间
    public let endTime: Date
    
    /// 请求持续时间（毫秒）
    public let duration: TimeInterval
    
    /// 内存使用（MB）
    public let memoryUsage: Double
    
    /// 网络流量（MB）
    public let networkTraffic: Double
    
    /// 是否超阈值
    public let isOverThreshold: Bool
    
    public init(
        requestId: String,
        url: String,
        method: String,
        startTime: Date,
        endTime: Date,
        duration: TimeInterval,
        memoryUsage: Double,
        networkTraffic: Double,
        isOverThreshold: Bool
    ) {
        self.requestId = requestId
        self.url = url
        self.method = method
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.memoryUsage = memoryUsage
        self.networkTraffic = networkTraffic
        self.isOverThreshold = isOverThreshold
    }
}

/// 性能监控管理器
public final class PerformanceMonitor {
    public static let shared = PerformanceMonitor()
    
    private var config: PerformanceMonitorConfig = PerformanceMonitorConfig()
    private var metrics: [PerformanceMetrics] = []
    // 使用简单的打印而不是自定义日志管理器
    // private let logger = NetworkLogger.shared
    private let queue = DispatchQueue(label: "com.fmnetcore.performance", qos: .utility)
    
    private init() {}
    
    /// 配置性能监控
    /// - Parameter config: 性能监控配置
    public func configure(with config: PerformanceMonitorConfig) {
        self.config = config
    }
    
    /// 获取当前配置
    /// - Returns: 性能监控配置
    public func getCurrentConfig() -> PerformanceMonitorConfig {
        return config
    }
    
    /// 开始监控请求
    /// - Parameters:
    ///   - requestId: 请求ID
    ///   - url: 请求URL
    ///   - method: HTTP方法
    /// - Returns: 开始时间
    @discardableResult
    public func startMonitoring(
        requestId: String,
        url: String,
        method: String
    ) -> Date {
        let startTime = Date()
        
        if config.enabled {
            logPerformance(.info, message: "🚀 开始监控请求: \(method) \(url) (ID: \(requestId))")
        }
        
        return startTime
    }
    
    /// 结束监控请求
    /// - Parameters:
    ///   - requestId: 请求ID
    ///   - url: 请求URL
    ///   - method: HTTP方法
    ///   - startTime: 开始时间
    ///   - dataSize: 数据大小（字节）
    public func endMonitoring(
        requestId: String,
        url: String,
        method: String,
        startTime: Date,
        dataSize: Int = 0
    ) {
        guard config.enabled else { return }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime) * 1000 // 转换为毫秒
        let isOverThreshold = duration > config.performanceThreshold
        
        // 获取内存使用情况
        let memoryUsage = getMemoryUsage()
        
        // 计算网络流量（MB）
        let networkTraffic = Double(dataSize) / (1024 * 1024)
        
        // 创建性能指标
        let metrics = PerformanceMetrics(
            requestId: requestId,
            url: url,
            method: method,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            memoryUsage: memoryUsage,
            networkTraffic: networkTraffic,
            isOverThreshold: isOverThreshold
        )
        
        // 存储指标
        queue.async { [weak self] in
            self?.metrics.append(metrics)
            
            // 限制存储的指标数量
            if self?.metrics.count ?? 0 > 1000 {
                self?.metrics.removeFirst(100)
            }
        }
        
        // 记录性能日志
        let logLevel: PerformanceLogLevel = isOverThreshold ? .warning : .info
        let message = "✅ 请求完成: \(method) \(url) (ID: \(requestId)) - 耗时: \(String(format: "%.2f", duration))ms, 内存: \(String(format: "%.2f", memoryUsage))MB, 流量: \(String(format: "%.2f", networkTraffic))MB"
        
        logPerformance(logLevel, message: message)
        
        // 如果超阈值，记录详细信息
        if isOverThreshold {
            logPerformance(.warning, message: "⚠️ 请求超阈值: \(method) \(url) (ID: \(requestId)) - 耗时: \(String(format: "%.2f", duration))ms > \(String(format: "%.2f", config.performanceThreshold))ms")
        }
        
        // 如果启用了详细指标，记录更多详细信息
        if config.detailedMetrics {
            logPerformance(.verbose, message: "📊 详细指标: \(method) \(url) (ID: \(requestId)) - 开始时间: \(startTime), 结束时间: \(endTime)")
        }
    }
    
    /// 获取内存使用情况
    /// - Returns: 内存使用量（MB）
    private func getMemoryUsage() -> Double {
        guard config.enableMemoryMonitoring else { return 0.0 }
        
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // 转换为MB
            return Double(taskInfo.resident_size) / (1024 * 1024)
        } else {
            return 0.0
        }
    }
    
    /// 记录性能日志
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    private func logPerformance(_ level: PerformanceLogLevel, message: String) {
        guard level.rawValue >= config.logLevel.rawValue else { return }
        
        // 简单打印日志而不是使用自定义日志管理器
        #if DEBUG
        print("[PerformanceMonitor] \(level) - \(message)")
        #endif
    }
    
    /// 获取所有性能指标
    /// - Returns: 性能指标数组
    public func getAllMetrics() -> [PerformanceMetrics] {
        return queue.sync { metrics }
    }
    
    /// 获取超阈值的性能指标
    /// - Returns: 超阈值的性能指标数组
    public func getOverThresholdMetrics() -> [PerformanceMetrics] {
        return queue.sync {
            metrics.filter { $0.isOverThreshold }
        }
    }
    
    /// 清除所有性能指标
    public func clearAllMetrics() {
        queue.async { [weak self] in
            self?.metrics.removeAll()
        }
    }
    
    /// 获取性能统计信息
    /// - Returns: 性能统计信息
    public func getPerformanceStats() -> PerformanceStats {
        return queue.sync {
            let totalRequests = metrics.count
            let overThresholdRequests = metrics.filter { $0.isOverThreshold }.count
            let averageDuration = metrics.isEmpty ? 0 : metrics.map { $0.duration }.reduce(0, +) / Double(metrics.count)
            let maxDuration = metrics.isEmpty ? 0 : metrics.map { $0.duration }.max() ?? 0
            let averageMemoryUsage = metrics.isEmpty ? 0 : metrics.map { $0.memoryUsage }.reduce(0, +) / Double(metrics.count)
            let totalNetworkTraffic = metrics.map { $0.networkTraffic }.reduce(0, +)
            
            return PerformanceStats(
                totalRequests: totalRequests,
                overThresholdRequests: overThresholdRequests,
                averageDuration: averageDuration,
                maxDuration: maxDuration,
                averageMemoryUsage: averageMemoryUsage,
                totalNetworkTraffic: totalNetworkTraffic
            )
        }
    }
}

/// 性能统计信息
public struct PerformanceStats {
    /// 总请求数
    public let totalRequests: Int
    
    /// 超阈值请求数
    public let overThresholdRequests: Int
    
    /// 平均请求时间（毫秒）
    public let averageDuration: TimeInterval
    
    /// 最大请求时间（毫秒）
    public let maxDuration: TimeInterval
    
    /// 平均内存使用（MB）
    public let averageMemoryUsage: Double
    
    /// 总网络流量（MB）
    public let totalNetworkTraffic: Double
    
    public init(
        totalRequests: Int,
        overThresholdRequests: Int,
        averageDuration: TimeInterval,
        maxDuration: TimeInterval,
        averageMemoryUsage: Double,
        totalNetworkTraffic: Double
    ) {
        self.totalRequests = totalRequests
        self.overThresholdRequests = overThresholdRequests
        self.averageDuration = averageDuration
        self.maxDuration = maxDuration
        self.averageMemoryUsage = averageMemoryUsage
        self.totalNetworkTraffic = totalNetworkTraffic
    }
}
