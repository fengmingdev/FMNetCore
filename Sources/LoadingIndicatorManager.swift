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

final class LoadingIndicatorManager {
    static let shared = LoadingIndicatorManager()
    private init() {}
    
    private var loadingCount = 0
    private let queue = DispatchQueue(label: "com.example.LoadingIndicatorManager.queue")
    
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
    
    // 显示加载视图
    func showLoading() {
        queue.sync {
            loadingCount += 1
            guard loadingCount == 1 else { return }
            
            #if canImport(UIKit)
            DispatchQueue.main.async {
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
            }
            #elseif canImport(AppKit)
            // macOS 实现
            DispatchQueue.main.async {
                // 在 macOS 上的实现
                // 这里可以使用 NSProgressIndicator 或其他 macOS 特定的 UI 元素
            }
            #else
            // 其他平台的实现
            #endif
        }
    }
    
    // 隐藏加载视图
    func hideLoading() {
        queue.sync {
            guard loadingCount > 0 else { return }
            loadingCount -= 1
            
            guard loadingCount == 0 else { return }
            
            #if canImport(UIKit)
            DispatchQueue.main.async {
                self.keyWindow?.viewWithTag(self.loadingViewTag)?.removeFromSuperview()
            }
            #elseif canImport(AppKit)
            // macOS 实现
            DispatchQueue.main.async {
                // 在 macOS 上的实现
            }
            #else
            // 其他平台的实现
            #endif
        }
    }
}