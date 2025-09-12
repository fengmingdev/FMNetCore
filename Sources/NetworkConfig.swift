//
//  NetworkConfig.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation

/// 代理配置结构体
struct ProxyConfig {
    /// 代理主机地址
    let host: String
    
    /// 代理端口
    let port: Int
    
    /// 是否启用HTTP代理
    let httpEnabled: Bool
    
    /// 是否启用HTTPS代理
    let httpsEnabled: Bool
    
    /// 用户名（可选）
    let username: String?
    
    /// 密码（可选）
    let password: String?
    
    /// 初始化代理配置
    /// - Parameters:
    ///   - host: 代理主机地址
    ///   - port: 代理端口
    ///   - httpEnabled: 是否启用HTTP代理，默认true
    ///   - httpsEnabled: 是否启用HTTPS代理，默认true
    ///   - username: 用户名（可选）
    ///   - password: 密码（可选）
    init(host: String, port: Int, httpEnabled: Bool = true, httpsEnabled: Bool = true, username: String? = nil, password: String? = nil) {
        self.host = host
        self.port = port
        self.httpEnabled = httpEnabled
        self.httpsEnabled = httpsEnabled
        self.username = username
        self.password = password
    }
}

struct NetworkConfig {
    /// 基础URL
    var baseURL: URL
    
    /// 全局请求头
    var headers: [String: String] = [:]
    
    /// 超时时间
    var timeoutInterval: TimeInterval = 10.0
    
    /// 是否开启日志
    var enableLogging: Bool = false
    
    /// 最大重试次数
    var maxRetryCount: Int = 2
    
    /// 重试间隔
    var retryInterval: TimeInterval = 1.0
    
    /// 弱网判断阈值
    var slowNetworkThreshold: TimeInterval = 3.0
    
    /// 日志文件路径
    var logFilePath: String?
    
    /// 是否记录请求体
    var logRequestBody: Bool = true
    
    /// 是否记录响应体
    var logResponseBody: Bool = true
    
    /// 代理配置（可选）
    var proxyConfig: ProxyConfig?
    
    /// 是否允许HTTP重定向
    var allowRedirects: Bool = true
    
    /// 最大重定向次数
    var maxRedirects: Int = 10
    
    /// SSL证书锁定配置文件路径（可选）
    var sslCertificatePath: String?
    
    /// 是否允许无效SSL证书
    var allowInvalidCertificates: Bool = false
}