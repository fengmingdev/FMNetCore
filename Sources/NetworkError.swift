//
//  NetworkError.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation

/// 网络错误枚举
enum NetworkError: Error, LocalizedError {
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
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "无数据返回"
        case .decodingError(let error):
            return "数据解码失败: \(error.localizedDescription)"
        case .serverError(let code):
            return "服务器错误，状态码: \(code)"
        case .httpError(let code):
            return "HTTP错误，状态码: \(code)"
        case .sslCertificateVerificationFailed:
            return "SSL证书验证失败"
        case .unknown:
            return "未知错误"
        case .weakNetwork:
            return "弱网环境"
        case .timeout:
            return "请求超时"
        case .networkUnreachable:
            return "网络不可达"
        case .weakNetworkNotAllowed:
            return "弱网环境不被允许"
        case .parsingError:
            return "数据解析错误"
        case .other(let error):
            return "其他错误: \(error.localizedDescription)"
        }
    }
}