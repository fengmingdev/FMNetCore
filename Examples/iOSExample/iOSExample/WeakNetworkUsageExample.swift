//
//  WeakNetworkUsageExample.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine
import FMNetCore

/// 弱网环境使用示例
class WeakNetworkUsageExample {
    
    /// 示例1: 区分关键请求和非关键请求
    func differentiateCriticalAndNonCriticalRequests() {
        // 定义一个关键请求（不允许在弱网环境下发送）
        struct CriticalRequest: APIRequest {
            typealias Target = UserAPI
            
            let userId: Int
            
            func asTarget() -> UserAPI {
                return .getUser(id: userId)
            }
            
            // 关键请求不允许在弱网环境下发送
            var allowsWeakNetwork: Bool { return false }
            var needsLoadingIndicator: Bool { return true }
        }
        
        // 定义一个非关键请求（允许在弱网环境下发送）
        struct NonCriticalRequest: APIRequest {
            typealias Target = UserAPI
            
            let userId: Int
            
            func asTarget() -> UserAPI {
                return .getUser(id: userId)
            }
            
            // 非关键请求允许在弱网环境下发送
            var allowsWeakNetwork: Bool { return true }
            var needsLoadingIndicator: Bool { return false }
        }
        
        // 发送关键请求
        let criticalRequest = CriticalRequest(userId: 1)
        NetworkManager.shared.request(criticalRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("关键请求完成")
                case .failure(let error):
                    // 直接处理NetworkError，因为request方法返回的就是NetworkError
                    switch error {
                    case .weakNetworkNotAllowed:
                        print("关键请求被拒绝：当前为弱网环境")
                    default:
                        print("关键请求失败: \(error)")
                    }
                }
            }, receiveValue: { (user: User) in
                print("获取关键用户: \(user.name)")
            })
            .store(in: &NetworkManager.shared.cancellables)
    }
    
    /// 示例2: 根据网络质量调整请求策略
    func adaptiveRequestStrategy() {
        // 定义一个可以根据网络质量调整的请求
        struct AdaptiveRequest: APIRequest {
            typealias Target = UserAPI
            
            let userId: Int
            
            func asTarget() -> UserAPI {
                return .getUser(id: userId)
            }
            
            // 根据当前网络质量决定是否允许请求
            var allowsWeakNetwork: Bool {
                switch ReachabilityManager.shared.networkStatus {
                case .cellular(let quality):
                    // 在较差的蜂窝网络下不允许请求
                    return quality != .poor
                default:
                    return true
                }
            }
            
            var needsLoadingIndicator: Bool { return true }
            
            // 根据网络质量调整超时时间
            var timeoutInterval: TimeInterval? {
                switch ReachabilityManager.shared.networkStatus {
                case .cellular(let quality):
                    switch quality {
                    case .excellent: return 5.0
                    case .good: return 10.0
                    case .fair: return 15.0
                    case .poor: return 20.0
                    default: return 10.0
                    }
                case .wifi:
                    return 5.0
                default:
                    return 10.0
                }
            }
        }
        
        let request = AdaptiveRequest(userId: 1)
        NetworkManager.shared.request<User>(request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("自适应请求完成")
                case .failure(let error):
                    print("自适应请求失败: \(error)")
                }
            }, receiveValue: { (user: User) in
                print("获取用户: \(user.name)")
            })
            .store(in: &NetworkManager.shared.cancellables)
    }
    
    /// 示例3: 弱网环境下的数据预加载
    func weakNetworkPreloading() {
        // 定义一个用于预加载的请求
        struct PreloadRequest: APIRequest {
            typealias Target = UserAPI
            
            let userId: Int
            
            func asTarget() -> UserAPI {
                return .getUser(id: userId)
            }
            
            // 预加载请求总是允许在弱网环境下发送
            var allowsWeakNetwork: Bool { return true }
            var needsLoadingIndicator: Bool { return false } // 预加载不需要显示加载指示器
        }
        
        // 在应用启动时预加载数据
        func preloadData() {
            let request = PreloadRequest(userId: 1)
            NetworkManager.shared.request<User>(request, useCache: true)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("预加载完成")
                    case .failure(let error):
                        print("预加载失败: \(error)")
                    }
                }, receiveValue: { (user: User) in
                    print("预加载用户数据: \(user.name)")
                })
                .store(in: &NetworkManager.shared.cancellables)
        }
        
        preloadData()
    }
    
    /// 示例4: 弱网环境监控和通知
    func weakNetworkMonitoring() {
        // 监听网络状态变化
        ReachabilityManager.shared.$networkStatus
            .sink { status in
                switch status {
                case .cellular(let quality) where quality == .poor:
                    // 检测到弱网环境，通知用户
                    NotificationCenter.default.post(
                        name: NSNotification.Name("WeakNetworkDetected"),
                        object: nil
                    )
                    print("⚠️ 检测到弱网环境，请注意数据使用")
                case .unreachable:
                    print("❌ 网络不可达")
                default:
                    break
                }
            }
            .store(in: &NetworkManager.shared.cancellables)
        
        // 监听弱网检测通知
        NotificationCenter.default.publisher(for: NSNotification.Name("WeakNetworkDetected"))
            .sink { _ in
                // 在弱网环境下采取相应措施
                self.handleWeakNetwork()
            }
            .store(in: &NetworkManager.shared.cancellables)
    }
    
    /// 处理弱网环境
    private func handleWeakNetwork() {
        print("正在处理弱网环境...")
        
        // 可以在这里实现弱网环境下的特殊逻辑
        // 例如：暂停大文件下载、减少请求频率、使用低质量图片等
    }
    
    /// 示例5: 弱网环境下的错误恢复
    func weakNetworkErrorRecovery() {
        // 定义一个具有错误恢复机制的请求
        struct RecoverableRequest: APIRequest {
            typealias Target = UserAPI
            
            let userId: Int
            
            func asTarget() -> UserAPI {
                return .getUser(id: userId)
            }
            
            // 允许在弱网环境下请求
            var allowsWeakNetwork: Bool { return true }
            var needsLoadingIndicator: Bool { return true }
            
            // 在弱网环境下增加重试次数
            var retryCount: Int? {
                switch ReachabilityManager.shared.networkStatus {
                case .cellular(let quality) where quality == .poor:
                    return 5 // 弱网环境下重试5次
                default:
                    return nil // 使用默认重试次数
                }
            }
        }
        
        let request = RecoverableRequest(userId: 1)
        NetworkManager.shared.request<User>(request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("可恢复请求完成")
                case .failure(let error):
                    print("可恢复请求失败: \(error)")
                    // 在弱网环境下失败时，可以提示用户稍后重试
                    self.promptUserToRetry()
                }
            }, receiveValue: { (user: User) in
                print("获取用户: \(user.name)")
            })
            .store(in: &NetworkManager.shared.cancellables)
    }
    
    /// 提示用户重试
    private func promptUserToRetry() {
        print("建议用户在网络状况改善后重试")
    }
}
