//
//  NetworkConfig.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation

/// 代理配置结构体
public struct ProxyConfig: Sendable {
    /// 代理主机地址
    public let host: String
    
    /// 代理端口
    public let port: Int
    
    /// 是否启用HTTP代理
    public let httpEnabled: Bool
    
    /// 是否启用HTTPS代理
    public let httpsEnabled: Bool
    
    /// 用户名（可选）
    public let username: String?
    
    /// 密码（可选）
    public let password: String?
    
    /// 初始化代理配置
    /// - Parameters:
    ///   - host: 代理主机地址
    ///   - port: 代理端口
    ///   - httpEnabled: 是否启用HTTP代理，默认true
    ///   - httpsEnabled: 是否启用HTTPS代理，默认true
    ///   - username: 用户名（可选）
    ///   - password: 密码（可选）
    public init(host: String, port: Int, httpEnabled: Bool = true, httpsEnabled: Bool = true, username: String? = nil, password: String? = nil) {
        self.host = host
        self.port = port
        self.httpEnabled = httpEnabled
        self.httpsEnabled = httpsEnabled
        self.username = username
        self.password = password
    }
}

public struct NetworkConfig: Sendable {
    /// 基础URL
    public var baseURL: URL
    
    /// 全局请求头
    public var headers: [String: String] = [:]
    
    /// 超时时间
    public var timeoutInterval: TimeInterval = 10.0
    
    /// 是否开启日志
    public var enableLogging: Bool = false
    
    /// 最大重试次数
    public var maxRetryCount: Int = 2
    
    /// 重试间隔
    public var retryInterval: TimeInterval = 1.0
    
    /// 弱网判断阈值
    public var slowNetworkThreshold: TimeInterval = 3.0
    
    /// 日志文件路径
    public var logFilePath: String?
    
    /// 是否记录请求体
    public var logRequestBody: Bool = true
    
    /// 是否记录响应体
    public var logResponseBody: Bool = true
    
    /// 代理配置（可选）
    public var proxyConfig: ProxyConfig?
    
    /// 是否允许HTTP重定向
    public var allowRedirects: Bool = true
    
    /// 最大重定向次数
    public var maxRedirects: Int = 10
    
    /// SSL证书锁定配置文件路径（可选）
    public var sslCertificatePath: String?
    
    /// 是否允许无效SSL证书
    public var allowInvalidCertificates: Bool = false
    
    /// 安全配置
    public var securityConfig: SecurityConfig = SecurityConfig()
    
    /// 初始化网络配置
    /// - Parameter baseURL: 基础URL
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}