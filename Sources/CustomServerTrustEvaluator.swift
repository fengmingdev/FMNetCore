//
//  CustomServerTrustEvaluator.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Alamofire

/// 自定义服务器信任评估器
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
final class CustomServerTrustEvaluator: ServerTrustEvaluating, Sendable {
    private let config: NetworkConfig
    
    /// 初始化自定义服务器信任评估器
    /// - Parameter config: 网络配置
    init(config: NetworkConfig) {
        self.config = config
    }
    
    /// 评估服务器信任
    /// - Parameters:
    ///   - trust: 服务器信任对象
    ///   - host: 主机名
    /// - Throws: 评估失败时抛出错误
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        // 如果允许无效证书，直接返回
        if config.allowInvalidCertificates {
            return
        }
        
        // 使用安全管理器验证证书
        if !SecurityManager.shared.validateServerCertificate(trust, forHost: host) {
            throw NetworkError.sslCertificateVerificationFailed
        }
        
        // 如果配置了证书锁定路径，验证证书
        if let certificatePath = config.sslCertificatePath {
            guard validateCertificate(trust: trust, certificatePath: certificatePath) else {
                throw NetworkError.sslCertificateVerificationFailed
            }
        }
        
        // 使用默认评估器进行评估
        try DefaultTrustEvaluator().evaluate(trust, forHost: host)
    }
    
    /// 验证证书
    /// - Parameters:
    ///   - trust: 服务器信任对象
    ///   - certificatePath: 证书文件路径
    /// - Returns: 证书是否有效
    private func validateCertificate(trust: SecTrust, certificatePath: String) -> Bool {
        // 获取本地证书
        guard let localCertificateData = try? Data(contentsOf: URL(fileURLWithPath: certificatePath)) else {
            return false
        }
        
        // 获取本地证书
        guard let localCertificate = SecCertificateCreateWithData(nil, localCertificateData as CFData) else {
            return false
        }
        
        // 获取服务器证书
        var serverCertificates: [SecCertificate] = []
        
        // 在这个类中，我们已经确保了iOS 15.0+的可用性，所以可以直接调用
        serverCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] ?? []
        
        // 检查服务器证书链中是否包含本地证书
        for serverCertificate in serverCertificates {
            if SecCertificateCopyData(serverCertificate) == SecCertificateCopyData(localCertificate) {
                return true
            }
        }
        
        return false
    }
}

// 为不支持新API的平台提供一个兼容版本
@available(macOS, introduced: 10.12, obsoleted: 12.0)
@available(iOS, introduced: 10.0, obsoleted: 15.0)
@available(watchOS, introduced: 3.0, obsoleted: 8.0)
@available(tvOS, introduced: 10.0, obsoleted: 15.0)
final class LegacyCustomServerTrustEvaluator: ServerTrustEvaluating, Sendable {
    private let config: NetworkConfig
    
    /// 初始化自定义服务器信任评估器
    /// - Parameter config: 网络配置
    init(config: NetworkConfig) {
        self.config = config
    }
    
    /// 评估服务器信任
    /// - Parameters:
    ///   - trust: 服务器信任对象
    ///   - host: 主机名
    /// - Throws: 评估失败时抛出错误
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        // 如果允许无效证书，直接返回
        if config.allowInvalidCertificates {
            return
        }
        
        // 使用安全管理器验证证书
        if !SecurityManager.shared.validateServerCertificate(trust, forHost: host) {
            throw NetworkError.sslCertificateVerificationFailed
        }
        
        // 使用默认评估器进行评估
        try DefaultTrustEvaluator().evaluate(trust, forHost: host)
    }
}