//
//  VersionManager.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
import Combine
// 直接导入项目中的相关文件

/// API版本
public enum APIVersion: String, CaseIterable {
    case v1 = "v1"
    case v2 = "v2"
    case v3 = "v3"
}

/// 版本兼容性策略
public enum VersionCompatibilityStrategy {
    /// 严格模式 - 只支持指定版本
    case strict
    
    /// 宽松模式 - 支持指定版本及以下版本
    case lenient
    
    /// 自动模式 - 自动适配最佳版本
    case automatic
}

/// 版本管理器
public final class VersionManager {
    public static let shared = VersionManager()
    
    private var currentAPIVersion: APIVersion = .v1
    private var compatibilityStrategy: VersionCompatibilityStrategy = .automatic
    private var deprecatedAPIs: Set<String> = []
    private var deprecatedVersions: Set<APIVersion> = []
    private let queue = DispatchQueue(label: "com.fmnetcore.version", qos: .utility)
    
    private init() {}
    
    /// 设置当前API版本
    /// - Parameter version: API版本
    public func setCurrentAPIVersion(_ version: APIVersion) {
        queue.async { [weak self] in
            self?.currentAPIVersion = version
        }
    }
    
    /// 获取当前API版本
    /// - Returns: 当前API版本
    public func getCurrentAPIVersion() -> APIVersion {
        return queue.sync { currentAPIVersion }
    }
    
    /// 设置兼容性策略
    /// - Parameter strategy: 兼容性策略
    public func setCompatibilityStrategy(_ strategy: VersionCompatibilityStrategy) {
        queue.async { [weak self] in
            self?.compatibilityStrategy = strategy
        }
    }
    
    /// 获取兼容性策略
    /// - Returns: 兼容性策略
    public func getCompatibilityStrategy() -> VersionCompatibilityStrategy {
        return queue.sync { compatibilityStrategy }
    }
    
    /// 标记API为已废弃
    /// - Parameter apiName: API名称
    public func deprecateAPI(_ apiName: String) {
        queue.async { [weak self] in
            self?.deprecatedAPIs.insert(apiName)
        }
    }
    
    /// 标记版本为已废弃
    /// - Parameter version: API版本
    public func deprecateVersion(_ version: APIVersion) {
        queue.async { [weak self] in
            self?.deprecatedVersions.insert(version)
        }
    }
    
    /// 检查API是否已废弃
    /// - Parameter apiName: API名称
    /// - Returns: 是否已废弃
    public func isAPI_DEPRECATED(_ apiName: String) -> Bool {
        return queue.sync { deprecatedAPIs.contains(apiName) }
    }
    
    /// 检查版本是否已废弃
    /// - Parameter version: API版本
    /// - Returns: 是否已废弃
    public func isVersion_DEPRECATED(_ version: APIVersion) -> Bool {
        return queue.sync { deprecatedVersions.contains(version) }
    }
    
    /// 获取API端点URL
    /// - Parameters:
    ///   - basePath: 基础路径
    ///   - version: API版本（可选，默认使用当前版本）
    /// - Returns: 完整的API端点URL
    public func getAPIEndpoint(
        basePath: String,
        version: APIVersion? = nil
    ) -> String {
        let targetVersion = version ?? getCurrentAPIVersion()
        
        // 检查版本是否已废弃
        if isVersion_DEPRECATED(targetVersion) {
            // 记录警告日志
            // NetworkLogger.shared.log(.warning, message: "使用已废弃的API版本: \(targetVersion.rawValue)")
        }
        
        // 根据兼容性策略调整版本
        let finalVersion = adjustVersion(for: targetVersion)
        
        // 构建完整的API端点URL
        var endpoint = basePath
        if !basePath.hasSuffix("/") {
            endpoint += "/"
        }
        endpoint += finalVersion.rawValue
        
        return endpoint
    }
    
    /// 调整版本以确保兼容性
    /// - Parameter version: 目标版本
    /// - Returns: 调整后的版本
    private func adjustVersion(for version: APIVersion) -> APIVersion {
        switch compatibilityStrategy {
        case .strict:
            // 严格模式，直接返回指定版本
            return version
            
        case .lenient:
            // 宽松模式，如果指定版本已废弃，尝试使用较低版本
            if isVersion_DEPRECATED(version) {
                // 查找可用的较低版本
                for availableVersion in APIVersion.allCases.reversed() {
                    if availableVersion.rawValue < version.rawValue && !isVersion_DEPRECATED(availableVersion) {
                        return availableVersion
                    }
                }
            }
            return version
            
        case .automatic:
            // 自动模式，选择最佳可用版本
            // 如果当前版本可用，使用当前版本
            if !isVersion_DEPRECATED(currentAPIVersion) {
                return currentAPIVersion
            }
            
            // 否则查找最佳可用版本
            for availableVersion in APIVersion.allCases.reversed() {
                if !isVersion_DEPRECATED(availableVersion) {
                    return availableVersion
                }
            }
            
            // 如果没有可用版本，返回原始版本
            return version
        }
    }
    
    /// 迁移数据到新版本
    /// - Parameters:
    ///   - data: 原始数据
    ///   - fromVersion: 源版本
    ///   - toVersion: 目标版本
    /// - Returns: 迁移后的数据
    public func migrateData(
        _ data: Data,
        from fromVersion: APIVersion,
        to toVersion: APIVersion
    ) -> Data? {
        // 检查是否需要迁移
        guard fromVersion != toVersion else {
            return data
        }
        
        // 记录迁移日志
        // NetworkLogger.shared.log(.info, message: "数据迁移: \(fromVersion.rawValue) -> \(toVersion.rawValue)")
        
        // 这里应该实现实际的数据迁移逻辑
        // 为示例，我们只是返回原始数据
        // 在实际应用中，应该根据版本差异进行数据转换
        return data
    }
    
    /// 获取版本兼容性报告
    /// - Returns: 版本兼容性报告
    public func getCompatibilityReport() -> VersionCompatibilityReport {
        return queue.sync {
            VersionCompatibilityReport(
                currentVersion: currentAPIVersion,
                deprecatedAPIs: Array(deprecatedAPIs),
                deprecatedVersions: Array(deprecatedVersions),
                compatibilityStrategy: compatibilityStrategy
            )
        }
    }
}

/// 版本兼容性报告
public struct VersionCompatibilityReport {
    /// 当前版本
    public let currentVersion: APIVersion
    
    /// 已废弃的API列表
    public let deprecatedAPIs: [String]
    
    /// 已废弃的版本列表
    public let deprecatedVersions: [APIVersion]
    
    /// 兼容性策略
    public let compatibilityStrategy: VersionCompatibilityStrategy
    
    public init(
        currentVersion: APIVersion,
        deprecatedAPIs: [String],
        deprecatedVersions: [APIVersion],
        compatibilityStrategy: VersionCompatibilityStrategy
    ) {
        self.currentVersion = currentVersion
        self.deprecatedAPIs = deprecatedAPIs
        self.deprecatedVersions = deprecatedVersions
        self.compatibilityStrategy = compatibilityStrategy
    }
}

/// 支持版本管理的API请求协议
public protocol VersionedAPIRequest {
    /// API版本
    var apiVersion: APIVersion? { get }
}

/// VersionedAPIRequest协议的默认实现
public extension VersionedAPIRequest {
    /// API版本（默认使用全局配置）
    var apiVersion: APIVersion? { return nil }
}
