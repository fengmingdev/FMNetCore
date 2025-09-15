//
//  APIRequest.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya

/// API请求协议
/// 定义网络请求的接口规范，所有网络请求都应该实现此协议
public protocol APIRequest {
    /// 对应的Moya TargetType
    associatedtype Target: TargetType
    
    /// 构建TargetType实例
    /// - Returns: TargetType实例
    func asTarget() -> Target
    
    /// 请求超时时间（可选，默认使用全局配置）
    var timeoutInterval: TimeInterval? { get }
    
    /// 是否允许弱网环境下请求（默认true）
    var allowsWeakNetwork: Bool { get }
    
    /// 重试次数（可选，默认使用全局配置）
    var retryCount: Int? { get }
    
    /// 是否需要显示加载指示器
    var needsLoadingIndicator: Bool { get }
}

/// APIRequest协议的默认实现
public extension APIRequest {
    /// 请求超时时间（可选，默认使用全局配置）
    var timeoutInterval: TimeInterval? { return nil }
    
    /// 是否允许弱网环境下请求（默认true）
    var allowsWeakNetwork: Bool { return true }
    
    /// 重试次数（可选，默认使用全局配置）
    var retryCount: Int? { return nil }
    
    /// 是否需要显示加载指示器（默认true）
    var needsLoadingIndicator: Bool { true }
}
