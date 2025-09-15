//
//  NetworkLogger.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// 网络日志插件
public final class MoyaNetworkLoggerPlugin: PluginType {
    private let logger = NetworkLogger.shared
    
    /// 准备请求
    /// - Parameters:
    ///   - request: 请求
    ///   - target: 目标
    /// - Returns: 修改后的请求
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        #if DEBUG
        var request = request
        
        // 添加通用请求头
        request.addValue("Networking/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0")", forHTTPHeaderField: "User-Agent")
        
        // 如果目标有自定义请求头，合并它们
        if let targetHeaders = target.headers {
            for (key, value) in targetHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
        #else
        return request
        #endif
    }
    
    /// 即将发送请求
    /// - Parameters:
    ///   - request: 请求
    ///   - target: 目标
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        // 创建日志消息
        var logMessage = "\n"
        logMessage += LocalizationManager.shared.localizedString(for: LocalizationKey.requestSending.rawValue, defaultValue: "🚀 [网络请求开始]\n")
        logMessage += LocalizationManager.shared.localizedString(for: "network.log.method", defaultValue: "🌐 方法: \(target.method)\n")
        logMessage += LocalizationManager.shared.localizedString(for: "network.log.url", defaultValue: "🔗 URL: \(target.baseURL)\(target.path)\n")
        
        // 记录请求头
        if let headers = target.headers, !headers.isEmpty {
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.request_headers", defaultValue: "📋 请求头:\n")
            for (key, value) in headers {
                logMessage += "   \(key): \(value)\n"
            }
        }
        
        // 记录请求参数
        if case .requestParameters(let parameters, _) = target.task {
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.request_parameters", defaultValue: "📦 请求参数:\n")
            for (key, value) in parameters {
                logMessage += "   \(key): \(value)\n"
            }
        }
        
        // 使用NetworkLogger记录日志而不是直接print
        NetworkLogger.shared.log(.info, message: logMessage)
        #endif
    }
    
    /// 接收到响应
    /// - Parameters:
    ///   - result: 结果
    ///   - target: 目标
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            // 创建成功日志消息
            var logMessage = "\n"
            logMessage += LocalizationManager.shared.localizedString(for: LocalizationKey.requestSuccess.rawValue, defaultValue: "✅ [请求成功]\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.method", defaultValue: "🌐 方法: \(target.method)\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.url", defaultValue: "🔗 URL: \(target.baseURL)\(target.path)\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.status_code", defaultValue: "🔢 状态码: \(response.statusCode)\n")
            
            // 记录响应头
            if let headers = response.response?.allHeaderFields, !headers.isEmpty {
                logMessage += LocalizationManager.shared.localizedString(for: "network.log.response_headers", defaultValue: "📋 响应头:\n")
                for (key, value) in headers {
                    if let key = key as? String, let value = value as? String {
                        logMessage += "   \(key): \(value)\n"
                    }
                }
            }
            
            // 使用NetworkLogger记录日志而不是直接print
            NetworkLogger.shared.log(.info, message: logMessage)
            
        case .failure(let error):
            // 创建失败日志消息
            var logMessage = "\n"
            logMessage += LocalizationManager.shared.localizedString(for: LocalizationKey.requestFailure.rawValue, defaultValue: "❌ [请求失败]\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.method", defaultValue: "🌐 方法: \(target.method)\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.url", defaultValue: "🔗 URL: \(target.baseURL)\(target.path)\n")
            logMessage += LocalizationManager.shared.localizedString(for: "network.log.error", defaultValue: "💥 错误: \(error)\n")
            
            // 使用NetworkLogger记录日志而不是直接print
            NetworkLogger.shared.log(.error, message: logMessage)
        }
        #endif
    }
    
    /// 处理结果
    /// - Parameters:
    ///   - result: 结果
    ///   - target: 目标
    /// - Returns: 处理后的结果
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
}

/// 网络日志记录器
public class NetworkLogger {
    /// 单例实例
    public static let shared = NetworkLogger()
    
    /// 日志级别枚举
    public enum LogLevel: Int, CaseIterable {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case none = 5
        
        public var description: String {
            switch self {
            case .verbose: return "VERBOSE"
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warning: return "WARNING"
            case .error: return "ERROR"
            case .none: return "NONE"
            }
        }
    }
    
    /// 日志配置
    public struct LogConfig {
        /// 最小日志级别
        public var minLogLevel: LogLevel = .info
        
        /// 是否记录请求体
        public var logRequestBody: Bool = true
        
        /// 是否记录响应体
        public var logResponseBody: Bool = true
        
        /// 是否记录请求头
        public var logRequestHeaders: Bool = true
        
        /// 是否记录响应头
        public var logResponseHeaders: Bool = true
        
        /// 最大日志条目数
        public var maxLogEntries: Int = 1000
        
        /// 日志文件路径
        public var logFilePath: String?
        
        public init() {}
    }
    
    /// 日志条目
    public struct LogEntry {
        public let timestamp: Date
        public let level: LogLevel
        public let message: String
        public let requestInfo: RequestInfo?
        public let responseInfo: ResponseInfo?
        
        public init(timestamp: Date, level: LogLevel, message: String, requestInfo: RequestInfo?, responseInfo: ResponseInfo?) {
            self.timestamp = timestamp
            self.level = level
            self.message = message
            self.requestInfo = requestInfo
            self.responseInfo = responseInfo
        }
    }
    
    /// 请求信息
    public struct RequestInfo {
        public let method: String
        public let url: String
        public let headers: [String: String]?
        public let body: Data?
        
        public init(method: String, url: String, headers: [String : String]?, body: Data?) {
            self.method = method
            self.url = url
            self.headers = headers
            self.body = body
        }
    }
    
    /// 响应信息
    public struct ResponseInfo {
        public let statusCode: Int
        public let headers: [String: String]?
        public let body: Data?
        public let duration: TimeInterval
        
        public init(statusCode: Int, headers: [String : String]?, body: Data?, duration: TimeInterval) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
            self.duration = duration
        }
    }
    
    /// 日志配置
    private var config: LogConfig
    
    /// 日志条目数组
    private var logEntries: [LogEntry] = []
    
    /// 日志队列
    private let logQueue = DispatchQueue(label: "com.networking.logger")
    
    /// 日志处理器
    private var logHandler: ((LogEntry) -> Void)?
    
    /// 初始化网络日志记录器
    /// - Parameter config: 日志配置
    public init(config: LogConfig = LogConfig()) {
        self.config = config
    }
    
    /// 设置日志处理器
    /// - Parameter handler: 日志处理器闭包
    public func setLogHandler(_ handler: @escaping (LogEntry) -> Void) {
        logHandler = handler
    }
    
    /// 记录日志
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    ///   - requestInfo: 请求信息（可选）
    ///   - responseInfo: 响应信息（可选）
    public func log(_ level: LogLevel, message: String, requestInfo: RequestInfo? = nil, responseInfo: ResponseInfo? = nil) {
        // 检查日志级别
        guard level.rawValue >= config.minLogLevel.rawValue else { return }
        
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            requestInfo: requestInfo,
            responseInfo: responseInfo
        )
        
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 添加到日志条目数组
            self.logEntries.append(entry)
            
            // 限制日志条目数量
            if self.logEntries.count > self.config.maxLogEntries {
                self.logEntries.removeFirst(self.logEntries.count - self.config.maxLogEntries)
            }
            
            // 调用日志处理器
            self.logHandler?(entry)
            
            // 如果有文件路径，写入文件
            if let filePath = self.config.logFilePath {
                self.writeToFile(entry, filePath: filePath)
            }
            
            // 在调试模式下打印到控制台
            #if DEBUG
            print("[\(entry.timestamp)] [\(entry.level.description)] \(entry.message)")
            #endif
        }
    }
    
    /// 写入文件
    /// - Parameters:
    ///   - entry: 日志条目
    ///   - filePath: 文件路径
    private func writeToFile(_ entry: LogEntry, filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        let logLine = "[\(entry.timestamp)] [\(entry.level.description)] \(entry.message)\n"
        
        // 追加到文件
        if let data = logLine.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: filePath) {
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: fileURL)
            }
        }
    }
    
    /// 获取所有日志条目
    /// - Returns: 日志条目数组
    public func getLogEntries() -> [LogEntry] {
        return logEntries
    }
    
    /// 清除所有日志条目
    public func clearLogEntries() {
        logEntries.removeAll()
    }
    
    /// 获取指定级别的日志条目
    /// - Parameter level: 日志级别
    /// - Returns: 日志条目数组
    public func getLogEntries(for level: LogLevel) -> [LogEntry] {
        return logEntries.filter { $0.level == level }
    }
}