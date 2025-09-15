//
//  NetworkError.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation

/// 网络错误枚举
public enum NetworkError: Error, LocalizedError {
    /// 无效URL
    case invalidURL
    
    /// 无数据返回
    case noData
    
    /// 数据解码失败
    case decodingError(error: DecodingError)
    
    /// 服务器错误
    case serverError(Int)
    
    /// HTTP错误
    case httpError(code: Int)
    
    /// SSL证书验证失败
    case sslCertificateVerificationFailed
    
    /// 未知错误
    case unknown
    
    /// 弱网环境下的错误
    case weakNetwork
    
    /// 超时错误
    case timeout
    
    /// 网络不可达
    case networkUnreachable
    
    /// 弱网不被允许
    case weakNetworkNotAllowed
    
    /// 解析错误
    case parsingError
    
    /// 自定义错误
    case other(error: Error)
    
    /// 错误描述
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.invalidURL.rawValue, defaultValue: "无效的URL")
        case .noData:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.noData.rawValue, defaultValue: "无数据返回")
        case .decodingError(let error):
            let defaultMessage = "数据解码失败: \(error.localizedDescription)"
            return LocalizationManager.shared.localizedString(for: LocalizationKey.decodingError.rawValue, defaultValue: defaultMessage)
        case .serverError(let code):
            let defaultMessage = "服务器错误，状态码: \(code)"
            return LocalizationManager.shared.localizedString(for: LocalizationKey.serverError.rawValue, defaultValue: defaultMessage, with: code)
        case .httpError(let code):
            let defaultMessage = "HTTP错误，状态码: \(code)"
            return LocalizationManager.shared.localizedString(for: LocalizationKey.httpError.rawValue, defaultValue: defaultMessage, with: code)
        case .sslCertificateVerificationFailed:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.sslCertificateVerificationFailed.rawValue, defaultValue: "SSL证书验证失败")
        case .unknown:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.unknownError.rawValue, defaultValue: "未知错误")
        case .weakNetwork:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.weakNetwork.rawValue, defaultValue: "弱网环境")
        case .timeout:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.timeout.rawValue, defaultValue: "请求超时")
        case .networkUnreachable:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.networkUnreachable.rawValue, defaultValue: "网络不可达")
        case .weakNetworkNotAllowed:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.weakNetworkNotAllowed.rawValue, defaultValue: "弱网环境不被允许")
        case .parsingError:
            return LocalizationManager.shared.localizedString(for: LocalizationKey.parsingError.rawValue, defaultValue: "数据解析错误")
        case .other(let error):
            let defaultMessage = "其他错误: \(error.localizedDescription)"
            return LocalizationManager.shared.localizedString(for: "network.error.other", defaultValue: defaultMessage)
        }
    }
}