//
//  DynamicBaseURL.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// 支持动态Base URL的协议
public protocol DynamicBaseURLTargetType: TargetType {
    /// 动态Base URL提供者
    var dynamicBaseURL: URL? { get }
    
    /// 默认Base URL
    var defaultBaseURL: URL { get }
}

/// 动态Base URL管理器
public class DynamicBaseURLManager {
    /// 单例实例
    public static let shared = DynamicBaseURLManager()
    
    /// 存储动态Base URL的字典
    public var dynamicBaseURLs: [String: URL] = [:]
    
    /// 队列用于线程安全
    private let queue = DispatchQueue(label: "DynamicBaseURLManagerQueue", attributes: .concurrent)
    
    /// 私有初始化方法
    public init() {}
    
    /// 设置动态Base URL
    /// - Parameters:
    ///   - url: Base URL
    ///   - key: 键名
    public func setDynamicBaseURL(_ url: URL, for key: String) {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs[key] = url
        }
    }
    
    /// 获取动态Base URL
    /// - Parameter key: 键名
    /// - Returns: Base URL
    public func getDynamicBaseURL(for key: String) -> URL? {
        return queue.sync {
            return dynamicBaseURLs[key]
        }
    }
    
    /// 移除动态Base URL
    /// - Parameter key: 键名
    public func removeDynamicBaseURL(for key: String) {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs.removeValue(forKey: key)
        }
    }
    
    /// 清空所有动态Base URL
    public func clearAllDynamicBaseURLs() {
        queue.async(flags: .barrier) {
            self.dynamicBaseURLs.removeAll()
        }
    }
}

/// 扩展TargetType以支持动态Base URL
public extension TargetType where Self: DynamicBaseURLTargetType {
    var baseURL: URL {
        // 如果有动态Base URL，使用动态的
        if let dynamicURL = dynamicBaseURL {
            return dynamicURL
        }
        
        // 否则使用默认的
        return defaultBaseURL
    }
}