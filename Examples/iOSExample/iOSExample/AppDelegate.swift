//
//  AppDelegate.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/12.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import FMNetCore

#if canImport(UIKit)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()
        
        // 配置网络管理器
        configureNetworkManager()
        
        return true
    }
    
    private func createRootViewController() -> UIViewController {
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    private func configureNetworkManager() {
        var config = NetworkConfig(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
        config.enableLogging = true
        config.maxRetryCount = 3
        
        // 创建网络管理器实例（这会替换单例实例）
        _ = NetworkManager(config: config, isTest: true)
    }
}
#endif
