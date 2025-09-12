//
//  ReachabilityManager.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import SystemConfiguration
import Combine
#if canImport(UIKit)
import UIKit
#endif

/// 网络质量枚举
enum NetworkQuality {
    case excellent  // 优秀
    case good       // 良好
    case fair       // 一般
    case poor       // 较差
}

/// 网络状态枚举
enum NetworkStatus {
    case unreachable
    case wifi
    case cellular(quality: NetworkQuality)
}

/// 网络可达性管理器
final class ReachabilityManager: ObservableObject {
    static let shared = ReachabilityManager()
    
    @Published private(set) var networkStatus: NetworkStatus = .wifi
    
    // 存储订阅
    internal var cancellables = Set<AnyCancellable>()
    
    private var reachability: SCNetworkReachability?
    private let queue = DispatchQueue(label: "com.example.ReachabilityManager.queue")
    
    private init() {
        setupReachability()
    }
    
    /// 设置网络可达性监测
    private func setupReachability() {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        
        let reachability = withUnsafePointer(to: &address) { addrPtr in
            addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        
        guard let reachability = reachability else {
            return
        }
        
        self.reachability = reachability
        
        let callback: SCNetworkReachabilityCallBack = { (_, flags, info) in
            guard let info = info else { return }
            let manager = Unmanaged<ReachabilityManager>.fromOpaque(info).takeUnretainedValue()
            manager.handleNetworkStatusChange(flags: flags)
        }
        
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        SCNetworkReachabilitySetCallback(reachability, callback, &context)
        SCNetworkReachabilitySetDispatchQueue(reachability, queue)
        
        // 获取初始状态
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            handleNetworkStatusChange(flags: flags)
        }
    }
    
    /// 处理网络状态变化
    /// - Parameter flags: 网络状态标志
    private func handleNetworkStatusChange(flags: SCNetworkReachabilityFlags) {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        // 检查是否是WWAN(蜂窝网络)
        #if canImport(UIKit) && !os(macOS)
        let isWWAN = flags.contains(.isWWAN)
        #else
        let isWWAN = false
        #endif
        
        if !isReachable || needsConnection {
            networkStatus = .unreachable
        } else if isWWAN {
            // 检查蜂窝网络质量
            let quality = checkCellularQuality()
            networkStatus = .cellular(quality: quality)
        } else {
            networkStatus = .wifi
        }
    }
    
    /// 检查蜂窝网络质量
    /// - Returns: 网络质量
    private func checkCellularQuality() -> NetworkQuality {
        // 这里可以实现更复杂的网络质量检测逻辑
        // 例如，通过测量网络延迟或带宽来判断质量
        return .good
    }
    
    /// 启动网络监测
    func startMonitoring() {
        // 监测已经在初始化时启动
    }
    
    /// 停止网络监测
    func stopMonitoring() {
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
}