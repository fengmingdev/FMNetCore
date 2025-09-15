//
//  EnvironmentManager.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation

/// 环境类型
public enum EnvironmentType: String, CaseIterable, Codable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    case testing = "testing"
}

/// 环境配置
public struct EnvironmentConfig {
    /// 环境类型
    public let type: EnvironmentType
    
    /// 基础URL
    public let baseURL: URL
    
    /// API版本
    public let apiVersion: String
    
    /// 超时时间
    public let timeoutInterval: TimeInterval
    
    /// 是否启用日志
    public let enableLogging: Bool
    
    /// 日志级别
    public let logLevel: NetworkLogger.LogLevel
    
    /// 最大重试次数
    public let maxRetryCount: Int
    
    /// 是否启用缓存
    public let enableCache: Bool
    
    /// 自定义配置
    public let customConfig: [String: Any]
    
    public init(
        type: EnvironmentType,
        baseURL: URL,
        apiVersion: String = "v1",
        timeoutInterval: TimeInterval = 10.0,
        enableLogging: Bool = false,
        logLevel: NetworkLogger.LogLevel = .info,
        maxRetryCount: Int = 2,
        enableCache: Bool = true,
        customConfig: [String: Any] = [:]
    ) {
        self.type = type
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.timeoutInterval = timeoutInterval
        self.enableLogging = enableLogging
        self.logLevel = logLevel
        self.maxRetryCount = maxRetryCount
        self.enableCache = enableCache
        self.customConfig = customConfig
    }
}

/// 环境管理器
public final class EnvironmentManager {
    public static let shared = EnvironmentManager()
    
    private var configs: [EnvironmentType: EnvironmentConfig] = [:]
    private var currentEnvironment: EnvironmentType = .development
    private let queue = DispatchQueue(label: "com.fmnetcore.environment", qos: .utility)
    
    private init() {
        setupDefaultConfigs()
    }
    
    /// 设置默认配置
    private func setupDefaultConfigs() {
        // 开发环境配置
        let devConfig = EnvironmentConfig(
            type: .development,
            baseURL: URL(string: "https://dev.api.example.com")!,
            apiVersion: "v1",
            timeoutInterval: 30.0,
            enableLogging: true,
            logLevel: .verbose,
            maxRetryCount: 3,
            enableCache: false,
            customConfig: ["debug": true]
        )
        
        // 测试环境配置
        let stagingConfig = EnvironmentConfig(
            type: .staging,
            baseURL: URL(string: "https://staging.api.example.com")!,
            apiVersion: "v1",
            timeoutInterval: 20.0,
            enableLogging: true,
            logLevel: .info,
            maxRetryCount: 2,
            enableCache: true,
            customConfig: ["staging": true]
        )
        
        // 生产环境配置
        let prodConfig = EnvironmentConfig(
            type: .production,
            baseURL: URL(string: "https://api.example.com")!,
            apiVersion: "v1",
            timeoutInterval: 10.0,
            enableLogging: false,
            logLevel: .error,
            maxRetryCount: 1,
            enableCache: true,
            customConfig: ["production": true]
        )
        
        // 测试环境配置
        let testConfig = EnvironmentConfig(
            type: .testing,
            baseURL: URL(string: "https://test.api.example.com")!,
            apiVersion: "v1",
            timeoutInterval: 15.0,
            enableLogging: true,
            logLevel: .debug,
            maxRetryCount: 0,
            enableCache: false,
            customConfig: ["testing": true]
        )
        
        configs[.development] = devConfig
        configs[.staging] = stagingConfig
        configs[.production] = prodConfig
        configs[.testing] = testConfig
    }
    
    /// 添加环境配置
    /// - Parameters:
    ///   - config: 环境配置
    ///   - environment: 环境类型
    public func addConfig(_ config: EnvironmentConfig, for environment: EnvironmentType) {
        queue.async { [weak self] in
            self?.configs[environment] = config
        }
    }
    
    /// 获取环境配置
    /// - Parameter environment: 环境类型
    /// - Returns: 环境配置
    public func getConfig(for environment: EnvironmentType) -> EnvironmentConfig? {
        return queue.sync { configs[environment] }
    }
    
    /// 设置当前环境
    /// - Parameter environment: 环境类型
    public func setCurrentEnvironment(_ environment: EnvironmentType) {
        queue.sync { currentEnvironment = environment }
        
        // 更新网络管理器配置
        updateNetworkManagerConfig()
    }
    
    /// 获取当前环境
    /// - Returns: 当前环境类型
    public func getCurrentEnvironment() -> EnvironmentType {
        return queue.sync { currentEnvironment }
    }
    
    /// 获取当前环境配置
    /// - Returns: 当前环境配置
    public func getCurrentConfig() -> EnvironmentConfig? {
        return queue.sync { configs[currentEnvironment] }
    }
    
    /// 更新网络管理器配置
    private func updateNetworkManagerConfig() {
        guard let config = getCurrentConfig() else { return }
        
        DispatchQueue.main.async {
            var networkConfig = NetworkManager.shared.config
            networkConfig.baseURL = config.baseURL
            networkConfig.timeoutInterval = config.timeoutInterval
            networkConfig.enableLogging = config.enableLogging
            networkConfig.maxRetryCount = config.maxRetryCount
            
            // 更新日志级别
            let logger = NetworkLogger.shared
            // 注意：这里需要根据需要更新日志配置
            
            NetworkManager.shared.config = networkConfig
        }
    }
    
    /// 从plist文件加载配置
    /// - Parameter fileName: plist文件名
    public func loadConfig(from fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return
        }
        
        queue.async { [weak self] in
            for (key, value) in dict {
                guard let envType = EnvironmentType(rawValue: key),
                      let envDict = value as? [String: Any] else {
                    continue
                }
                
                self?.parseAndAddConfig(envDict, for: envType)
            }
        }
    }
    
    /// 解析并添加配置
    /// - Parameters:
    ///   - dict: 配置字典
    ///   - environment: 环境类型
    private func parseAndAddConfig(_ dict: [String: Any], for environment: EnvironmentType) {
        guard let baseURLString = dict["baseURL"] as? String,
              let baseURL = URL(string: baseURLString) else {
            return
        }
        
        let apiVersion = dict["apiVersion"] as? String ?? "v1"
        let timeoutInterval = dict["timeoutInterval"] as? TimeInterval ?? 10.0
        let enableLogging = dict["enableLogging"] as? Bool ?? false
        let logLevelRaw = dict["logLevel"] as? String ?? "info"
        let logLevel = parseLogLevel(from: logLevelRaw)
        let maxRetryCount = dict["maxRetryCount"] as? Int ?? 2
        let enableCache = dict["enableCache"] as? Bool ?? true
        let customConfig = dict["customConfig"] as? [String: Any] ?? [:]
        
        let config = EnvironmentConfig(
            type: environment,
            baseURL: baseURL,
            apiVersion: apiVersion,
            timeoutInterval: timeoutInterval,
            enableLogging: enableLogging,
            logLevel: logLevel,
            maxRetryCount: maxRetryCount,
            enableCache: enableCache,
            customConfig: customConfig
        )
        
        configs[environment] = config
    }
    
    /// 解析日志级别
    /// - Parameter logLevelString: 日志级别字符串
    /// - Returns: 日志级别
    private func parseLogLevel(from logLevelString: String) -> NetworkLogger.LogLevel {
        switch logLevelString.lowercased() {
        case "verbose":
            return .verbose
        case "debug":
            return .debug
        case "warning":
            return .warning
        case "error":
            return .error
        case "none":
            return .none
        default:
            return .info
        }
    }
    
    /// 获取所有环境配置
    /// - Returns: 所有环境配置
    public func getAllConfigs() -> [EnvironmentType: EnvironmentConfig] {
        return queue.sync { configs }
    }
    
    /// 清除所有配置
    public func clearAllConfigs() {
        queue.async { [weak self] in
            self?.configs.removeAll()
            self?.setupDefaultConfigs()
        }
    }
}