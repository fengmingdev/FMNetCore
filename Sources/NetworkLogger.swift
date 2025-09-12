//
//  NetworkLogger.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// 网络日志插件
final class MoyaNetworkLoggerPlugin: PluginType {
    private let logger = NetworkLogger.shared
    
    /// 准备请求
    /// - Parameters:
    ///   - request: 请求
    ///   - target: 目标
    /// - Returns: 修改后的请求
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
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
    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        // 创建日志消息
        var logMessage = "\n🚀 [网络请求开始]\n"
        logMessage += "🌐 方法: \(target.method)\n"
        logMessage += "🔗 URL: \(target.baseURL)\(target.path)\n"
        
        // 记录请求头
        if let headers = target.headers, !headers.isEmpty {
            logMessage += "📋 请求头:\n"
            for (key, value) in headers {
                logMessage += "   \(key): \(value)\n"
            }
        }
        
        // 记录请求参数
        if case .requestParameters(let parameters, _) = target.task {
            logMessage += "📦 请求参数:\n"
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
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            // 创建成功日志消息
            var logMessage = "\n✅ [请求成功]\n"
            logMessage += "🌐 方法: \(target.method)\n"
            logMessage += "🔗 URL: \(target.baseURL)\(target.path)\n"
            logMessage += "🔢 状态码: \(response.statusCode)\n"
            
            // 记录响应头
            if let headers = response.response?.allHeaderFields, !headers.isEmpty {
                logMessage += "📋 响应头:\n"
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
            var logMessage = "\n❌ [请求失败]\n"
            logMessage += "🌐 方法: \(target.method)\n"
            logMessage += "🔗 URL: \(target.baseURL)\(target.path)\n"
            logMessage += "💥 错误: \(error)\n"
            
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
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
}

/// 网络日志记录器
class NetworkLogger {
    /// 单例实例
    static let shared = NetworkLogger()
    
    /// 日志级别枚举
    enum LogLevel: Int, CaseIterable {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case none = 5
        
        var description: String {
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
    struct LogConfig {
        /// 最小日志级别
        var minLogLevel: LogLevel = .info
        
        /// 是否记录请求体
        var logRequestBody: Bool = true
        
        /// 是否记录响应体
        var logResponseBody: Bool = true
        
        /// 是否记录请求头
        var logRequestHeaders: Bool = true
        
        /// 是否记录响应头
        var logResponseHeaders: Bool = true
        
        /// 最大日志条目数
        var maxLogEntries: Int = 1000
        
        /// 日志文件路径
        var logFilePath: String?
    }
    
    /// 日志条目
    struct LogEntry {
        let timestamp: Date
        let level: LogLevel
        let message: String
        let requestInfo: RequestInfo?
        let responseInfo: ResponseInfo?
    }
    
    /// 请求信息
    struct RequestInfo {
        let method: String
        let url: String
        let headers: [String: String]?
        let body: Data?
    }
    
    /// 响应信息
    struct ResponseInfo {
        let statusCode: Int
        let headers: [String: String]?
        let body: Data?
        let duration: TimeInterval
    }
    
    /// 日志配置
    private var config: LogConfig
    
    /// 日志条目数组
    private var logEntries: [LogEntry] = []
    
    /// 日志队列
    private let logQueue = DispatchQueue(label: "com.networking.logger", qos: .background)
    
    /// 私有初始化方法
    private init(config: LogConfig = LogConfig()) {
        self.config = config
        setupFileLogging()
    }
    
    /// 设置文件日志记录
    private func setupFileLogging() {
        guard let logFilePath = config.logFilePath else { return }
        
        // 创建日志目录
        let fileURL = URL(fileURLWithPath: logFilePath)
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// 记录日志
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    ///   - requestInfo: 请求信息（可选）
    ///   - responseInfo: 响应信息（可选）
    func log(_ level: LogLevel, 
             message: String, 
             requestInfo: RequestInfo? = nil, 
             responseInfo: ResponseInfo? = nil) {
        // 检查日志级别
        guard level.rawValue >= config.minLogLevel.rawValue else { return }
        
        let logEntry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            requestInfo: requestInfo,
            responseInfo: responseInfo
        )
        
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 添加日志条目
            self.logEntries.append(logEntry)
            
            // 限制日志条目数量
            if self.logEntries.count > self.config.maxLogEntries {
                self.logEntries.removeFirst(self.logEntries.count - self.config.maxLogEntries)
            }
            
            // 输出到控制台
            self.outputToConsole(logEntry)
            
            // 输出到文件
            self.outputToFile(logEntry)
        }
    }
    
    /// 输出到控制台
    private func outputToConsole(_ logEntry: LogEntry) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = formatter.string(from: logEntry.timestamp)
        
        print("[\(timestamp)] [\(logEntry.level.description)] \(logEntry.message)")
        
        // 输出请求信息
        if let requestInfo = logEntry.requestInfo {
            print("  🔧 请求: \(requestInfo.method) \(requestInfo.url)")
            
            if config.logRequestHeaders, let headers = requestInfo.headers {
                print("  📄 请求头:")
                for (key, value) in headers {
                    print("    \(key): \(value)")
                }
            }
            
            if config.logRequestBody, let body = requestInfo.body,
               let bodyString = String(data: body, encoding: .utf8) {
                print("  📦 请求体: \(bodyString)")
            }
        }
        
        // 输出响应信息
        if let responseInfo = logEntry.responseInfo {
            print("  📡 响应: 状态码 \(responseInfo.statusCode) (耗时: \(String(format: "%.2f", responseInfo.duration * 1000))ms)")
            
            if config.logResponseHeaders, let headers = responseInfo.headers {
                print("  📄 响应头:")
                for (key, value) in headers {
                    print("    \(key): \(value)")
                }
            }
            
            if config.logResponseBody, let body = responseInfo.body,
               let bodyString = String(data: body, encoding: .utf8) {
                print("  📦 响应体: \(bodyString)")
            }
        }
    }
    
    /// 输出到文件
    private func outputToFile(_ logEntry: LogEntry) {
        guard let logFilePath = config.logFilePath else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = formatter.string(from: logEntry.timestamp)
        
        var logString = "[\(timestamp)] [\(logEntry.level.description)] \(logEntry.message)\n"
        
        // 添加请求信息
        if let requestInfo = logEntry.requestInfo {
            logString += "  🔧 请求: \(requestInfo.method) \(requestInfo.url)\n"
            
            if config.logRequestHeaders, let headers = requestInfo.headers {
                logString += "  📄 请求头:\n"
                for (key, value) in headers {
                    logString += "    \(key): \(value)\n"
                }
            }
            
            if config.logRequestBody, let body = requestInfo.body,
               let bodyString = String(data: body, encoding: .utf8) {
                logString += "  📦 请求体: \(bodyString)\n"
            }
        }
        
        // 添加响应信息
        if let responseInfo = logEntry.responseInfo {
            logString += "  📡 响应: 状态码 \(responseInfo.statusCode) (耗时: \(String(format: "%.2f", responseInfo.duration * 1000))ms)\n"
            
            if config.logResponseHeaders, let headers = responseInfo.headers {
                logString += "  📄 响应头:\n"
                for (key, value) in headers {
                    logString += "    \(key): \(value)\n"
                }
            }
            
            if config.logResponseBody, let body = responseInfo.body,
               let bodyString = String(data: body, encoding: .utf8) {
                logString += "  📦 响应体: \(bodyString)\n"
            }
        }
        
        logString += "\n"
        
        // 写入文件
        if let data = logString.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFilePath) {
                FileHandle(forWritingAtPath: logFilePath)?.seekToEndOfFile()
                FileHandle(forWritingAtPath: logFilePath)?.write(data)
            } else {
                try? data.write(to: URL(fileURLWithPath: logFilePath))
            }
        }
    }
    
    /// 获取所有日志条目
    /// - Returns: 日志条目数组
    func getLogEntries() -> [LogEntry] {
        return logQueue.sync {
            return logEntries
        }
    }
    
    /// 清除所有日志
    func clearLogs() {
        logQueue.async { [weak self] in
            self?.logEntries.removeAll()
            
            // 清除日志文件
            if let logFilePath = self?.config.logFilePath {
                try? FileManager.default.removeItem(atPath: logFilePath)
            }
        }
    }
    
    /// 根据级别过滤日志
    /// - Parameter level: 日志级别
    /// - Returns: 过滤后的日志条目数组
    func getLogEntries(for level: LogLevel) -> [LogEntry] {
        return logQueue.sync {
            return logEntries.filter { $0.level == level }
        }
    }
    
    /// 根据时间范围过滤日志
    /// - Parameters:
    ///   - startDate: 开始时间
    ///   - endDate: 结束时间
    /// - Returns: 过滤后的日志条目数组
    func getLogEntries(from startDate: Date, to endDate: Date) -> [LogEntry] {
        return logQueue.sync {
            return logEntries.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
        }
    }
    
    /// 导出日志到文件
    /// - Parameter filePath: 导出文件路径
    func exportLogs(to filePath: String) {
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            var exportString = "Networking Logs Export\n"
            exportString += "=====================\n\n"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            
            for entry in self.logEntries {
                let timestamp = formatter.string(from: entry.timestamp)
                exportString += "[\(timestamp)] [\(entry.level.description)] \(entry.message)\n"
                
                if let requestInfo = entry.requestInfo {
                    exportString += "  Request: \(requestInfo.method) \(requestInfo.url)\n"
                }
                
                if let responseInfo = entry.responseInfo {
                    exportString += "  Response: Status \(responseInfo.statusCode) (Duration: \(String(format: "%.2f", responseInfo.duration * 1000))ms)\n"
                }
                
                exportString += "\n"
            }
            
            // 写入文件
            if let data = exportString.data(using: .utf8) {
                try? data.write(to: URL(fileURLWithPath: filePath))
            }
        }
    }
}
