//
//  NetworkSimulation.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import FMNetCore

/// 网络模拟工具
class NetworkSimulation {
    /// 网络环境枚举
    enum NetworkEnvironment {
        case excellentWifi      // 优秀的WiFi网络
        case goodWifi          // 良好的WiFi网络
        case poorWifi          // 较差的WiFi网络
        case excellentCellular // 优秀的蜂窝网络
        case goodCellular      // 良好的蜂窝网络
        case fairCellular      // 一般的蜂窝网络
        case poorCellular      // 较差的蜂窝网络（弱网）
        case unreachable       // 网络不可达
    }
    
    /// 模拟网络环境
    /// - Parameter environment: 要模拟的网络环境
    static func simulateNetworkEnvironment(_ environment: NetworkEnvironment) {
        // 注意：由于networkStatus是只读属性，我们不能直接设置它
        // 在实际应用中，这个方法应该通过其他方式来模拟网络环境
        // 例如，通过配置网络拦截器或使用测试框架
        
        print("模拟网络环境: \(description(for: environment))")
        
        // 根据环境类型，我们可以设置一些全局配置来影响网络行为
        switch environment {
        case .excellentWifi, .goodWifi, .poorWifi:
            // WiFi环境
            print("设置WiFi环境配置")
        case .excellentCellular, .goodCellular, .fairCellular, .poorCellular:
            // 蜂窝网络环境
            print("设置蜂窝网络环境配置")
        case .unreachable:
            // 网络不可达环境
            print("设置网络不可达环境配置")
        }
    }
    
    /// 模拟网络延迟
    /// - Parameters:
    ///   - minDelay: 最小延迟（秒）
    ///   - maxDelay: 最大延迟（秒）
    static func simulateNetworkDelay(minDelay: TimeInterval, maxDelay: TimeInterval) {
        // 这个方法可以在实际的网络请求中添加延迟来模拟网络环境
        // 在实际应用中，可以通过配置URLSession的超时时间来实现
    }
    
    /// 模拟网络丢包
    /// - Parameter packetLossRate: 丢包率（0.0-1.0）
    static func simulatePacketLoss(packetLossRate: Double) {
        // 这个方法可以在实际的网络请求中随机失败来模拟丢包
        // 在实际应用中，可以通过网络拦截器来实现
    }
    
    /// 获取环境描述
    /// - Parameter environment: 网络环境
    /// - Returns: 环境描述字符串
    static func description(for environment: NetworkEnvironment) -> String {
        switch environment {
        case .excellentWifi:
            return "优秀的WiFi网络"
        case .goodWifi:
            return "良好的WiFi网络"
        case .poorWifi:
            return "较差的WiFi网络"
        case .excellentCellular:
            return "优秀的蜂窝网络"
        case .goodCellular:
            return "良好的蜂窝网络"
        case .fairCellular:
            return "一般的蜂窝网络"
        case .poorCellular:
            return "较差的蜂窝网络（弱网）"
        case .unreachable:
            return "网络不可达"
        }
    }
    
    /// 获取所有网络环境选项
    /// - Returns: 网络环境选项数组
    static func allEnvironments() -> [NetworkEnvironment] {
        return [
            .excellentWifi,
            .goodWifi,
            .poorWifi,
            .excellentCellular,
            .goodCellular,
            .fairCellular,
            .poorCellular,
            .unreachable
        ]
    }
}

/// 弱网测试工具
class WeakNetworkTestTool {
    /// 测试在不同网络环境下的请求行为
    /// - Parameters:
    ///   - request: 要测试的请求
    ///   - environments: 要测试的网络环境数组
    ///   - completion: 测试完成回调
    static func testRequest<T: APIRequest>(_ request: T, 
                                          in environments: [NetworkSimulation.NetworkEnvironment],
                                          completion: @escaping (NetworkSimulation.NetworkEnvironment, Result<Data?, Error>) -> Void) {
        // 创建分发组来等待所有测试完成
        let dispatchGroup = DispatchGroup()
        var results: [NetworkSimulation.NetworkEnvironment: Result<Data?, Error>] = [:]
        
        // 在每个网络环境下测试请求
        for environment in environments {
            dispatchGroup.enter()
            
            // 模拟网络环境
            NetworkSimulation.simulateNetworkEnvironment(environment)
            
            // 这里需要实际发送请求并等待结果
            // 由于这是一个示例，我们使用延迟来模拟网络请求
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                // 模拟请求结果
                let success = environment != .unreachable && environment != .poorCellular
                let result: Result<Data?, Error> = success ? .success(nil) : .failure(NetworkError.networkUnreachable)
                
                results[environment] = result
                completion(environment, result)
                dispatchGroup.leave()
            }
        }
        
        // 等待所有测试完成
        dispatchGroup.notify(queue: .main) {
            print("所有网络环境测试完成")
        }
    }
    
    /// 生成弱网测试报告
    /// - Parameters:
    ///   - results: 测试结果字典
    ///   - requestType: 请求类型描述
    /// - Returns: 测试报告字符串
    static func generateTestReport(results: [NetworkSimulation.NetworkEnvironment: Result<Data?, Error>],
                                  for requestType: String) -> String {
        var report = "弱网测试报告 - \(requestType)\n"
        report += "========================\n\n"
        
        for (environment, result) in results {
            let environmentDescription = NetworkSimulation.description(for: environment)
            let resultDescription: String
            
            switch result {
            case .success:
                resultDescription = "✅ 成功"
            case .failure:
                resultDescription = "❌ 失败"
            }
            
            report += "\(environmentDescription): \(resultDescription)\n"
        }
        
        // 统计信息
        let successCount = results.values.filter { if case .success = $0 { return true }; return false }.count
        let totalCount = results.count
        let successRate = totalCount > 0 ? Double(successCount) / Double(totalCount) * 100 : 0
        
        report += "\n统计信息:\n"
        report += "总测试数: \(totalCount)\n"
        report += "成功数: \(successCount)\n"
        report += "成功率: \(String(format: "%.2f", successRate))%\n"
        
        return report
    }
}
