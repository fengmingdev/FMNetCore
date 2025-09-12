//
//  DynamicBaseURL.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// 支持动态Base URL的协议
protocol DynamicBaseURLTargetType: TargetType {
    /// 动态Base URL提供者
    var dynamicBaseURL: URL? { get }
}

/// 动态Base URL管理器
class DynamicBaseURLManager {
    /// 单例实例
    static let shared = DynamicBaseURLManager()
    
    /// 存储动态Base URL的字典
    private var dynamicBaseURLs: [String: URL] = [:]
    
    /// 队列用于线程安全
    private let queue = DispatchQueue(label: "DynamicBaseURLManagerQueue", attributes: .concurrent)
    
    /// 私有初始化方法
    private init() {}
    
    /// 设置动态Base URL
    /// - Parameters:
    ///   - url: Base URL
    ///   - key: 键名
    func setDynamicBaseURL(_ url: URL, for key: String) {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs[key] = url
        }
    }
    
    /// 获取动态Base URL
    /// - Parameter key: 键名
    /// - Returns: Base URL
    func getDynamicBaseURL(for key: String) -> URL? {
        return queue.sync {
            return dynamicBaseURLs[key]
        }
    }
    
    /// 移除动态Base URL
    /// - Parameter key: 键名
    func removeDynamicBaseURL(for key: String) {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs.removeValue(forKey: key)
        }
    }
    
    /// 清空所有动态Base URL
    func clearAllDynamicBaseURLs() {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs.removeAll()
        }
    }
}

/// 扩展TargetType以支持动态Base URL
extension TargetType where Self: DynamicBaseURLTargetType {
    var baseURL: URL {
        // 如果有动态Base URL，使用动态的
        if let dynamicURL = dynamicBaseURL {
            return dynamicURL
        }
        
        // 否则使用默认的
        return defaultBaseURL
    }
    
    /// 子类需要实现这个属性来提供默认的Base URL
    var defaultBaseURL: URL {
        // 默认实现，子类应该重写这个属性
        return URL(string: "https://api.example.com")!
    }
}