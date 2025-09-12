//
//  NetworkURLSessionDelegate.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Alamofire

/// 网络URLSession代理类，用于处理重定向和SSL证书验证
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
class NetworkURLSessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDelegate {
    
    private let config: NetworkConfig
    
    /// 初始化网络URLSession代理
    /// - Parameter config: 网络配置
    init(config: NetworkConfig) {
        self.config = config
    }
    
    /// 处理任务重定向
    /// - Parameters:
    ///   - session: URLSession实例
    ///   - task: URLSessionTask实例
    ///   - response: HTTPURLResponse实例
    ///   - request: URLRequest实例
    ///   - completionHandler: 完成回调
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // 如果不允许重定向，直接返回nil
        guard config.allowRedirects else {
            completionHandler(nil)
            return
        }
        
        // 获取重定向次数
        var redirectCount = 0
        if let taskDescription = task.currentRequest?.description,
           let range = taskDescription.range(of: "redirectCount="),
           let countString = String(taskDescription[range.upperBound...]).components(separatedBy: "&").first,
           let count = Int(countString) {
            redirectCount = count
        }
        
        // 如果重定向次数超过限制，不允许继续重定向
        if redirectCount >= config.maxRedirects {
            completionHandler(nil)
            return
        }
        
        // 增加重定向次数并继续重定向
        var newRequest = request
        newRequest.cachePolicy = .reloadIgnoringLocalCacheData
        completionHandler(newRequest)
    }
    
    /// 处理任务完成
    /// - Parameters:
    ///   - session: URLSession实例
    ///   - task: URLSessionTask实例
    ///   - error: Error实例
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // 处理任务完成逻辑
    }
    
    /// 处理认证挑战
    /// - Parameters:
    ///   - session: URLSession实例
    ///   - challenge: URLAuthenticationChallenge实例
    ///   - completionHandler: 完成回调
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // 如果配置了自定义服务器信任评估器，使用它来处理挑战
        if config.sslCertificatePath != nil || config.allowInvalidCertificates {
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                guard validateCertificate(challenge: challenge, certificatePath: config.sslCertificatePath ?? "") else {
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
            }
        }
        
        // 使用默认处理方式
        completionHandler(.performDefaultHandling, nil)
    }
    
    /// 验证证书
    /// - Parameters:
    ///   - challenge: URLAuthenticationChallenge实例
    ///   - certificatePath: 证书文件路径
    /// - Returns: 证书是否有效
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    private func validateCertificate(challenge: URLAuthenticationChallenge, certificatePath: String) -> Bool {
        // 获取服务器证书
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return false
        }
        
        // 获取服务器证书
        var serverCertificates: [SecCertificate] = []
        
        // 在这个可用性检查范围内，我们可以直接调用新API
        serverCertificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []
        
        // 获取本地证书
        guard let localCertificateData = try? Data(contentsOf: URL(fileURLWithPath: certificatePath)) else {
            return false
        }
        
        guard let localCertificate = SecCertificateCreateWithData(nil, localCertificateData as CFData) else {
            return false
        }
        
        // 检查服务器证书链中是否包含本地证书
        for serverCertificate in serverCertificates {
            if SecCertificateCopyData(serverCertificate) == SecCertificateCopyData(localCertificate) {
                return true
            }
        }
        
        return false
    }
}