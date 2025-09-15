//
//  CustomLoadingIndicatorExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

#if canImport(MBProgressHUD)
import MBProgressHUD
#endif

#if canImport(Toast_Swift)
import Toast_Swift

/// 使用Toast-Swift的自定义加载指示器示例
class ToastLoadingIndicator: LoadingIndicator {
    private weak var toastView: UIView?
    
    func show() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        // 使用Toast-Swift显示加载提示
        window.makeToastActivity(.center)
    }
    
    func hide() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.hide()
            }
            return
        }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        // 隐藏Toast-Swift加载提示
        window.hideToastActivity()
    }
    
    func willShow() {
        // 可以在这里添加显示前的逻辑
        print("ToastLoadingIndicator will show")
    }
    
    func didShow() {
        // 可以在这里添加显示后的逻辑
        print("ToastLoadingIndicator did show")
    }
    
    func willHide() {
        // 可以在这里添加隐藏前的逻辑
        print("ToastLoadingIndicator will hide")
    }
    
    func didHide() {
        // 可以在这里添加隐藏后的逻辑
        print("ToastLoadingIndicator did hide")
    }
}
#endif
#if canImport(MBProgressHUD)
/// 使用MBProgressHUD的自定义加载指示器示例
class MBProgressHUDLoadingIndicator: LoadingIndicator {
    private weak var hud: MBProgressHUD?
    
    func show() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        
        if let window = UIApplication.shared.keyWindow {
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.label.text = "加载中..."
            self.hud = hud
        }
    }
    
    func hide() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.hide()
            }
            return
        }
        
        self.hud?.hide(animated: true)
    }
    
    func willShow() {
        // 可以在这里添加显示前的逻辑
        print("MBProgressHUDLoadingIndicator will show")
    }
    
    func didShow() {
        // 可以在这里添加显示后的逻辑
        print("MBProgressHUDLoadingIndicator did show")
    }
    
    func willHide() {
        // 可以在这里添加隐藏前的逻辑
        print("MBProgressHUDLoadingIndicator will hide")
    }
    
    func didHide() {
        // 可以在这里添加隐藏后的逻辑
        print("MBProgressHUDLoadingIndicator did hide")
    }
}
#endif
/// 使用系统UIActivityIndicatorView的自定义加载指示器示例
class CustomActivityIndicatorView: LoadingIndicator {
    private var loadingView: UIView?
    
    func show() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show()
            }
            return
        }
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        // 创建半透明背景
        let backgroundView = UIView(frame: keyWindow.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.tag = 999999 // 使用特殊tag以便识别
        
        // 避免重复添加
        if keyWindow.viewWithTag(999999) != nil {
            return
        }
        
        // 创建加载指示器
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        // 设置指示器位置
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
        
        keyWindow.addSubview(backgroundView)
        self.loadingView = backgroundView
    }
    
    func hide() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.hide()
            }
            return
        }
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        self.loadingView?.removeFromSuperview()
        self.loadingView = nil
        
        // 移除可能存在的tag视图
        keyWindow.viewWithTag(999999)?.removeFromSuperview()
    }
    
    func willShow() {
        // 可以在这里添加显示前的逻辑
        print("CustomActivityIndicatorView will show")
    }
    
    func didShow() {
        // 可以在这里添加显示后的逻辑
        print("CustomActivityIndicatorView did show")
    }
    
    func willHide() {
        // 可以在这里添加隐藏前的逻辑
        print("CustomActivityIndicatorView will hide")
    }
    
    func didHide() {
        // 可以在这里添加隐藏后的逻辑
        print("CustomActivityIndicatorView did hide")
    }
}

/// 配置自定义加载指示器的示例
class LoadingIndicatorConfigurationExample {
    static func configureCustomLoadingIndicator() {
        // 方法1: 使用MBProgressHUD（需要添加MBProgressHUD依赖）
        // LoadingIndicatorManager.shared.setIndicator(MBProgressHUDLoadingIndicator())
        
        // 方法2: 使用自定义的ActivityIndicatorView
        LoadingIndicatorManager.shared.setIndicator(CustomActivityIndicatorView())
        
        // 方法3: 使用Toast-Swift
        // LoadingIndicatorManager.shared.setIndicator(ToastLoadingIndicator())
        
        // 配置显示和隐藏延迟
        let config = LoadingIndicatorConfig(showDelay: 0.3, hideDelay: 0.1)
        LoadingIndicatorManager.shared.configure(with: config)
    }
    
    /// 配置Toast-Swift加载指示器
    static func configureToastLoadingIndicator() {
        #if canImport(Toast_Swift)
        LoadingIndicatorManager.shared.setIndicator(ToastLoadingIndicator())
        
        // 配置显示和隐藏延迟
        let config = LoadingIndicatorConfig(showDelay: 0.1, hideDelay: 0.1)
        LoadingIndicatorManager.shared.configure(with: config)
        #endif
    }
}
