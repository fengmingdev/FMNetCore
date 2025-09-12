//
//  CustomRedirectHandler.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Alamofire

/// 自定义重定向处理器
final class CustomRedirectHandler: RedirectHandler, @unchecked Sendable {
    private let config: NetworkConfig
    
    /// 初始化自定义重定向处理器
    /// - Parameter config: 网络配置
    init(config: NetworkConfig) {
        self.config = config
    }
    
    /// 处理重定向
    /// - Parameters:
    ///   - task: URLSessionTask实例
    ///   - request: 新的请求
    ///   - response: HTTP重定向响应
    ///   - completion: 完成回调
    func task(_ task: URLSessionTask, willBeRedirectedTo request: URLRequest, for response: HTTPURLResponse, completion: @escaping (URLRequest?) -> Void) {
        // 如果不允许重定向，返回nil
        guard config.allowRedirects else {
            completion(nil)
            return
        }
        
        // 检查重定向次数是否超过限制
        // 使用task的taskDescription来存储重定向计数
        var redirectCount = 0
        if let taskDescription = task.taskDescription,
           let count = Int(taskDescription) {
            redirectCount = count
        }
        
        if redirectCount >= config.maxRedirects {
            completion(nil)
            return
        }
        
        // 增加重定向计数并设置到taskDescription中
        let newRedirectCount = redirectCount + 1
        task.taskDescription = "\(newRedirectCount)"
        
        // 继续重定向
        completion(request)
    }
}