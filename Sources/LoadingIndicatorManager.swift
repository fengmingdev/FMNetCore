//
//  LoadingIndicatorManager.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

/// 加载指示器协议，用于自定义加载视图的显示和隐藏
public protocol LoadingIndicator: AnyObject {
    /// 显示加载指示器
    func show()
    
    /// 隐藏加载指示器
    func hide()
    
    /// 可选方法：加载指示器将要显示时调用
    func willShow()
    
    /// 可选方法：加载指示器已经显示时调用
    func didShow()
    
    /// 可选方法：加载指示器将要隐藏时调用
    func willHide()
    
    /// 可选方法：加载指示器已经隐藏时调用
    func didHide()
}

/// 为 LoadingIndicator 协议提供默认实现
public extension LoadingIndicator {
    func willShow() {
        // 默认空实现
    }
    
    func didShow() {
        // 默认空实现
    }
    
    func willHide() {
        // 默认空实现
    }
    
    func didHide() {
        // 默认空实现
    }
}

/// 加载指示器配置
public struct LoadingIndicatorConfig {
    /// 显示延迟时间（秒）
    public var showDelay: TimeInterval
    
    /// 隐藏延迟时间（秒）
    public var hideDelay: TimeInterval
    
    /// 是否启用防重复显示（默认true）
    public var preventDuplicateShow: Bool
    
    /// 最小显示时间（秒），防止闪烁
    public var minimumDisplayTime: TimeInterval
    
    public init(
        showDelay: TimeInterval = 0.5,
        hideDelay: TimeInterval = 0.0,
        preventDuplicateShow: Bool = true,
        minimumDisplayTime: TimeInterval = 0.1
    ) {
        self.showDelay = showDelay
        self.hideDelay = hideDelay
        self.preventDuplicateShow = preventDuplicateShow
        self.minimumDisplayTime = minimumDisplayTime
    }
}

/// 默认的加载指示器实现
open class DefaultLoadingIndicator: LoadingIndicator {
    #if canImport(UIKit)
    private let loadingViewTag = 9999
    
    // 获取当前keyWindow的兼容方法
    private var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    #endif
    
    public init() {}
    
    open func show() {
        #if canImport(UIKit)
        // 直接在主线程执行，避免不必要的调度
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        
        // 确保只添加一个加载视图
        guard self.keyWindow?.viewWithTag(self.loadingViewTag) == nil else { return }
        
        let loadingView = UIView()
        loadingView.tag = self.loadingViewTag
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.frame = UIScreen.main.bounds
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = loadingView.center
        indicator.startAnimating()
        
        loadingView.addSubview(indicator)
        self.keyWindow?.addSubview(loadingView)
        #elseif canImport(AppKit)
        // macOS 实现
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        // 在 macOS 上的实现
        #else
        // 其他平台的实现
        #endif
    }
    
    open func hide() {
        #if canImport(UIKit)
        // 直接在主线程执行，避免不必要的调度
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.hide()
            }
            return
        }
        
        self.keyWindow?.viewWithTag(self.loadingViewTag)?.removeFromSuperview()
        #elseif canImport(AppKit)
        // macOS 实现
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.hide()
            }
            return
        }
        // 在 macOS 上的实现
        #else
        // 其他平台的实现
        #endif
    }
    
    open func willShow() {
        // 默认实现
        print("DefaultLoadingIndicator will show")
    }
    
    open func didShow() {
        // 默认实现
        print("DefaultLoadingIndicator did show")
    }
    
    open func willHide() {
        // 默认实现
        print("DefaultLoadingIndicator will hide")
    }
    
    open func didHide() {
        // 默认实现
        print("DefaultLoadingIndicator did hide")
    }
}

/// 加载任务信息
public struct LoadingTaskInfo {
    /// 任务ID
    public let taskId: UUID
    
    /// 创建时间
    public let createdAt: Date
    
    /// 是否正在显示
    public let isVisible: Bool
    
    public init(taskId: UUID, createdAt: Date, isVisible: Bool) {
        self.taskId = taskId
        self.createdAt = createdAt
        self.isVisible = isVisible
    }
}

/// 内部任务信息结构
private struct InternalTaskInfo {
    let taskId: UUID
    let createdAt: Date
    var isVisible: Bool
    
    init(taskId: UUID, createdAt: Date) {
        self.taskId = taskId
        self.createdAt = createdAt
        self.isVisible = false
    }
}

public final class LoadingIndicatorManager {
    public static let shared = LoadingIndicatorManager()
    
    /// 当前加载任务计数
    private var loadingCount = 0
    
    /// 任务ID映射，用于跟踪所有加载任务及其信息
    private var tasks: [UUID: InternalTaskInfo] = [:]
    
    /// 当前可见的加载任务ID
    private var visibleTaskId: UUID?
    
    /// 加载开始时间
    private var showStartTime: Date?
    
    /// 配置选项
    private var config: LoadingIndicatorConfig
    
    /// 当前使用的加载指示器实现
    private var currentIndicator: LoadingIndicator
    
    /// 串行队列用于线程安全
    private let queue = DispatchQueue(label: "com.example.LoadingIndicatorManager.queue", qos: .userInitiated)
    
    /// 专门用于UI更新的队列
    private let uiQueue = DispatchQueue.main
    
    private init() {
        self.config = LoadingIndicatorConfig()
        self.currentIndicator = DefaultLoadingIndicator()
    }
    
    /// 配置加载指示器
    /// - Parameter config: 配置选项
    public func configure(with config: LoadingIndicatorConfig) {
        queue.sync {
            self.config = config
        }
    }
    
    /// 设置自定义加载指示器
    /// - Parameter indicator: 实现了LoadingIndicator协议的实例
    public func setIndicator(_ indicator: LoadingIndicator) {
        queue.sync {
            self.currentIndicator = indicator
        }
    }
    
    /// 获取当前配置
    public func getCurrentConfig() -> LoadingIndicatorConfig {
        return queue.sync {
            self.config
        }
    }
    
    /// 获取当前加载任务数量
    public func getLoadingCount() -> Int {
        return queue.sync {
            self.loadingCount
        }
    }
    
    /// 检查加载指示器是否可见
    public func isVisible() -> Bool {
        return queue.sync {
            self.visibleTaskId != nil
        }
    }
    
    /// 获取当前可见任务的ID（如果有的话）
    public func getVisibleTaskId() -> UUID? {
        return queue.sync {
            self.visibleTaskId
        }
    }
    
    /// 获取所有加载任务信息
    public func getAllTasks() -> [LoadingTaskInfo] {
        return queue.sync {
            var taskInfos: [LoadingTaskInfo] = []
            for (_, taskInfo) in self.tasks {
                let info = LoadingTaskInfo(
                    taskId: taskInfo.taskId,
                    createdAt: taskInfo.createdAt,
                    isVisible: taskInfo.taskId == self.visibleTaskId
                )
                taskInfos.append(info)
            }
            return taskInfos
        }
    }
    
    /// 显示加载视图
    /// - Returns: 任务ID，可用于跟踪和取消
    @discardableResult
    public func showLoading() -> UUID {
        let taskId = UUID()
        let creationTime = Date()
        
        queue.async {
            // 添加任务到映射中
            self.tasks[taskId] = InternalTaskInfo(taskId: taskId, createdAt: creationTime)
            
            // 增加加载计数
            self.loadingCount += 1
            
            // 检查是否需要显示加载指示器
            let shouldShow = self.loadingCount == 1 || !self.config.preventDuplicateShow
            
            guard shouldShow else {
                return
            }
            
            // 记录显示开始时间
            self.showStartTime = Date()
            
            // 调用willShow回调
            self.currentIndicator.willShow()
            
            // 延迟显示加载指示器
            self.uiQueue.asyncAfter(deadline: .now() + self.config.showDelay) {
                // 检查任务是否仍然有效
                guard self.queue.sync(execute: { self.tasks[taskId] != nil }) else {
                    return
                }
                
                self.currentIndicator.show()
                
                self.queue.async {
                    // 更新任务可见状态
                    if var taskInfo = self.tasks[taskId] {
                        taskInfo.isVisible = true
                        self.tasks[taskId] = taskInfo
                    }
                    
                    self.visibleTaskId = taskId
                }
                
                // 调用didShow回调
                self.currentIndicator.didShow()
            }
        }
        
        return taskId
    }
    
    /// 隐藏加载视图
    /// - Parameter taskId: 任务ID，如果为nil则隐藏所有加载指示器
    public func hideLoading(for taskId: UUID? = nil) {
        queue.async {
            var shouldHide = false
            
            // 如果提供了任务ID，从映射中移除
            if let taskId = taskId {
                if self.tasks[taskId] != nil {
                    // 减少加载计数
                    if self.loadingCount > 0 {
                        self.loadingCount -= 1
                    }
                    
                    // 如果这是当前可见的任务，需要隐藏
                    if taskId == self.visibleTaskId {
                        shouldHide = true
                        self.visibleTaskId = nil
                    }
                    
                    // 移除任务
                    self.tasks.removeValue(forKey: taskId)
                }
            } else {
                // 移除所有任务
                let hadVisibleTask = self.visibleTaskId != nil
                self.tasks.removeAll()
                self.loadingCount = 0
                
                if hadVisibleTask {
                    shouldHide = true
                    self.visibleTaskId = nil
                }
            }
            
            // 检查是否需要隐藏加载指示器
            guard shouldHide else {
                return
            }
            
            // 计算最小显示时间
            var hideDelay = self.config.hideDelay
            if let startTime = self.showStartTime {
                let elapsed = Date().timeIntervalSince(startTime)
                let remaining = self.config.minimumDisplayTime - elapsed
                if remaining > 0 {
                    hideDelay = max(hideDelay, remaining)
                }
            }
            
            // 调用willHide回调
            self.currentIndicator.willHide()
            
            // 延迟隐藏加载指示器
            self.uiQueue.asyncAfter(deadline: .now() + hideDelay) {
                self.currentIndicator.hide()
                
                // 调用didHide回调
                self.currentIndicator.didHide()
                
                self.queue.async {
                    self.showStartTime = nil
                }
            }
        }
    }
    
    /// 取消特定任务的加载指示器
    /// - Parameter taskId: 要取消的任务ID
    public func cancelLoading(for taskId: UUID) {
        hideLoading(for: taskId)
    }
    
    /// 取消所有加载指示器
    public func cancelAllLoading() {
        hideLoading(for: nil)
    }
}