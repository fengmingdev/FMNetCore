//
//  SecurityManager.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
import Security

/// 安全配置
public struct SecurityConfig {
    /// 是否启用证书锁定
    public var enableCertificatePinning: Bool = false
    
    /// 证书锁定模式
    public var certificatePinningMode: CertificatePinningMode = .publicKey
    
    /// 证书文件路径数组
    public var certificatePaths: [String] = []
    
    /// 是否启用客户端证书认证
    public var enableClientCertificateAuthentication: Bool = false
    
    /// 客户端证书路径
    public var clientCertificatePath: String?
    
    /// 客户端证书密码
    public var clientCertificatePassword: String?
    
    /// 是否加密请求参数
    public var encryptRequestParameters: Bool = false
    
    /// 是否加密响应数据
    public var encryptResponseData: Bool = false
    
    /// 加密密钥
    public var encryptionKey: String?
    
    public init() {}
}

/// 证书锁定模式
public enum CertificatePinningMode {
    /// 公钥锁定
    case publicKey
    
    /// 证书锁定
    case certificate
    
    /// 不锁定
    case none
}

/// 安全管理器
public final class SecurityManager {
    public static let shared = SecurityManager()
    
    private var config: SecurityConfig = SecurityConfig()
    
    private init() {}
    
    /// 配置安全设置
    /// - Parameter config: 安全配置
    public func configure(with config: SecurityConfig) {
        self.config = config
    }
    
    /// 获取当前安全配置
    /// - Returns: 安全配置
    public func getCurrentConfig() -> SecurityConfig {
        return config
    }
    
    /// 验证服务器证书
    /// - Parameters:
    ///   - serverTrust: 服务器信任对象
    ///   - host: 主机名
    /// - Returns: 验证结果
    public func validateServerCertificate(_ serverTrust: SecTrust, forHost host: String) -> Bool {
        guard config.enableCertificatePinning else {
            return true
        }
        
        guard !config.certificatePaths.isEmpty else {
            return true
        }
        
        // 获取服务器证书（适配新旧版本）
        var serverCertificate: SecCertificate?
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            // 新版本使用SecTrustCopyCertificateChain
            if let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate], !certificates.isEmpty {
                serverCertificate = certificates[0]
            }
        } else {
            // 旧版本使用SecTrustGetCertificateAtIndex
            serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        }
        
        guard let serverCertificate = serverCertificate else {
            return false
        }
        
        // 根据锁定模式验证证书
        switch config.certificatePinningMode {
        case .publicKey:
            return validatePublicKey(serverCertificate, withPinnedCertificates: config.certificatePaths)
        case .certificate:
            return validateCertificate(serverCertificate, withPinnedCertificates: config.certificatePaths)
        case .none:
            return true
        }
    }
    
    /// 验证公钥
    /// - Parameters:
    ///   - serverCertificate: 服务器证书
    ///   - pinnedCertificatePaths: 锁定的证书路径
    /// - Returns: 验证结果
    private func validatePublicKey(_ serverCertificate: SecCertificate, withPinnedCertificates pinnedCertificatePaths: [String]) -> Bool {
        // 获取服务器证书的公钥
        guard let serverPublicKey = SecCertificateCopyKey(serverCertificate) else {
            return false
        }
        
        // 获取服务器公钥数据
        guard let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
            return false
        }
        
        // 比较与锁定证书的公钥
        for path in pinnedCertificatePaths {
            guard let pinnedCertificateData = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData as CFData),
                  let pinnedPublicKey = SecCertificateCopyKey(pinnedCertificate),
                  let pinnedPublicKeyData = SecKeyCopyExternalRepresentation(pinnedPublicKey, nil) else {
                continue
            }
            
            // 比较公钥数据
            if serverPublicKeyData as Data == pinnedPublicKeyData as Data {
                return true
            }
        }
        
        return false
    }
    
    /// 验证证书
    /// - Parameters:
    ///   - serverCertificate: 服务器证书
    ///   - pinnedCertificatePaths: 锁定的证书路径
    /// - Returns: 验证结果
    private func validateCertificate(_ serverCertificate: SecCertificate, withPinnedCertificates pinnedCertificatePaths: [String]) -> Bool {
        // 获取服务器证书数据
        let serverCertificateData = SecCertificateCopyData(serverCertificate)
        
        // 比较与锁定证书的数据
        for path in pinnedCertificatePaths {
            guard let pinnedCertificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                continue
            }
            
            // 比较证书数据
            if serverCertificateData as Data == pinnedCertificateData {
                return true
            }
        }
        
        return false
    }
    
    /// 加密数据
    /// - Parameter data: 要加密的数据
    /// - Returns: 加密后的数据
    public func encrypt(_ data: Data) -> Data? {
        guard config.encryptRequestParameters, config.encryptionKey != nil else {
            return data
        }
        
        // 这里应该实现实际的加密逻辑
        // 为了示例，我们只是简单地返回原始数据
        // 在实际应用中，应该使用适当的加密算法
        return data
    }
    
    /// 解密数据
    /// - Parameter data: 要解密的数据
    /// - Returns: 解密后的数据
    public func decrypt(_ data: Data) -> Data? {
        guard config.encryptResponseData, config.encryptionKey != nil else {
            return data
        }
        
        // 这里应该实现实际的解密逻辑
        // 为了示例，我们只是简单地返回原始数据
        // 在实际应用中，应该使用适当的解密算法
        return data
    }
}