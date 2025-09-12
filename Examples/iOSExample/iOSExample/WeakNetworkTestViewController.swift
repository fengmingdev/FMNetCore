//
//  WeakNetworkTestViewController.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import UIKit
import Combine
import FMNetCore

class WeakNetworkTestViewController: UIViewController {
    
    private var tableView: UITableView!
    private var resultTextView: UITextView!
    private var allowsWeakNetworkSwitch: UISwitch!
    private var networkStatusLabel: UILabel!
    
    // 存储订阅
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateNetworkStatusDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "弱网环境测试"
        
        // 创建网络状态标签
        networkStatusLabel = UILabel()
        networkStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        networkStatusLabel.textAlignment = .center
        networkStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        networkStatusLabel.backgroundColor = .systemGray6
        networkStatusLabel.layer.cornerRadius = 8
        networkStatusLabel.clipsToBounds = true
        view.addSubview(networkStatusLabel)
        
        // 创建开关
        let switchLabel = UILabel()
        switchLabel.text = "允许弱网请求:"
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        allowsWeakNetworkSwitch = UISwitch()
        allowsWeakNetworkSwitch.isOn = false
        allowsWeakNetworkSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let switchStackView = UIStackView(arrangedSubviews: [switchLabel, allowsWeakNetworkSwitch])
        switchStackView.axis = .horizontal
        switchStackView.spacing = 10
        switchStackView.alignment = .center
        switchStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchStackView)
        
        // 创建按钮
        let testButton = UIButton(type: .system)
        testButton.setTitle("测试当前环境", for: .normal)
        testButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.addTarget(self, action: #selector(testCurrentEnvironmentTapped), for: .touchUpInside)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        let testAllButton = UIButton(type: .system)
        testAllButton.setTitle("测试所有环境", for: .normal)
        testAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        testAllButton.backgroundColor = .systemGreen
        testAllButton.setTitleColor(.white, for: .normal)
        testAllButton.layer.cornerRadius = 8
        testAllButton.addTarget(self, action: #selector(testAllEnvironmentsTapped), for: .touchUpInside)
        testAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView(arrangedSubviews: [testButton, testAllButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // 创建结果文本视图
        resultTextView = UITextView()
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.backgroundColor = .systemGray6
        resultTextView.layer.cornerRadius = 8
        resultTextView.clipsToBounds = true
        resultTextView.isEditable = false
        view.addSubview(resultTextView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            networkStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            networkStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            networkStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            networkStatusLabel.heightAnchor.constraint(equalToConstant: 40),
            
            switchStackView.topAnchor.constraint(equalTo: networkStatusLabel.bottomAnchor, constant: 20),
            switchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            switchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: switchStackView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resultTextView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateNetworkStatusDisplay() {
        let statusText: String
        let backgroundColor: UIColor
        
        switch ReachabilityManager.shared.networkStatus {
        case .unreachable:
            statusText = "网络状态: 不可达"
            backgroundColor = .systemRed
        case .wifi:
            statusText = "网络状态: Wi-Fi"
            backgroundColor = .systemGreen
        case .cellular(let quality):
            switch quality {
            case .excellent:
                statusText = "网络状态: 蜂窝网络(优秀)"
                backgroundColor = .systemGreen
            case .good:
                statusText = "网络状态: 蜂窝网络(良好)"
                backgroundColor = .systemYellow
            case .fair:
                statusText = "网络状态: 蜂窝网络(一般)"
                backgroundColor = .systemOrange
            case .poor:
                statusText = "网络状态: 蜂窝网络(较差)"
                backgroundColor = .systemRed
            }
        }
        
        networkStatusLabel.text = statusText
        networkStatusLabel.backgroundColor = backgroundColor
    }
    
    @objc private func testCurrentEnvironmentTapped() {
        resultTextView.text = "开始测试当前网络环境...\n\n"
        
        // 创建请求
        let allowsWeakNetwork = allowsWeakNetworkSwitch.isOn
        struct WeakNetworkTestRequest: APIRequest {
            typealias Target = UserAPI
            let allowsWeakNetworkValue: Bool
            
            init(allowsWeakNetworkValue: Bool) {
                self.allowsWeakNetworkValue = allowsWeakNetworkValue
            }
            
            func asTarget() -> UserAPI {
                return .getUser(id: 1)
            }
            
            var allowsWeakNetwork: Bool { 
                return allowsWeakNetworkValue
            }
            
            var needsLoadingIndicator: Bool { 
                return true 
            }
        }
        
        let request = WeakNetworkTestRequest(allowsWeakNetworkValue: allowsWeakNetwork)
        
        // 发送请求
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.resultTextView.text += "✅ 请求完成\n"
                        case .failure(let error):
                            self?.resultTextView.text += "❌ 请求失败: \(error)\n"
                            // 直接处理NetworkError，因为request方法返回的就是NetworkError
                            switch error {
                            case .weakNetworkNotAllowed:
                                self?.resultTextView.text += "   原因: 当前为弱网环境且请求不允许在弱网下发送\n"
                            case .networkUnreachable:
                                self?.resultTextView.text += "   原因: 网络不可达\n"
                            case .timeout:
                                self?.resultTextView.text += "   原因: 请求超时\n"
                            default:
                                break
                            }
                        }
                    }
                },
                receiveValue: { [weak self] (_: User) in  // 明确指定类型
                    DispatchQueue.main.async {
                        self?.resultTextView.text += "✅ 请求成功\n"
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    @objc private func testAllEnvironmentsTapped() {
        resultTextView.text = "开始测试所有网络环境...\n\n"
        
        // 创建请求
        let allowsWeakNetwork = allowsWeakNetworkSwitch.isOn
        struct WeakNetworkTestRequest: APIRequest {
            typealias Target = UserAPI
            let allowsWeakNetworkValue: Bool
            
            init(allowsWeakNetworkValue: Bool) {
                self.allowsWeakNetworkValue = allowsWeakNetworkValue
            }
            
            func asTarget() -> UserAPI {
                return .getUser(id: 1)
            }
            
            var allowsWeakNetwork: Bool { 
                return allowsWeakNetworkValue
            }
            
            var needsLoadingIndicator: Bool { 
                return true 
            }
        }
        
        let request = WeakNetworkTestRequest(allowsWeakNetworkValue: allowsWeakNetwork)
        let environments = NetworkSimulation.allEnvironments()
        
        // 用于存储测试结果
        var results: [NetworkSimulation.NetworkEnvironment: Result<Data?, Error>] = [:]
        
        // 创建分发组
        let dispatchGroup = DispatchGroup()
        
        // 在每个网络环境下测试请求
        for environment in environments {
            dispatchGroup.enter()
            
            // 模拟网络环境
            NetworkSimulation.simulateNetworkEnvironment(environment)
            updateNetworkStatusDisplay()
            
            // 延迟一小段时间以确保UI更新
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 发送请求
                NetworkManager.shared.request<User>(request)
                    .sink(
                        receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                            DispatchQueue.main.async {
                                switch completion {
                                case .finished:
                                    results[environment] = .success(nil)
                                    self?.resultTextView.text += "✅ \(NetworkSimulation.description(for: environment)): 成功\n"
                                case .failure(let error):
                                    results[environment] = .failure(error)
                                    self?.resultTextView.text += "❌ \(NetworkSimulation.description(for: environment)): 失败 - \(error)\n"
                                }
                                dispatchGroup.leave()
                            }
                        },
                        receiveValue: { [weak self] (_: User) in
                            // 不需要处理成功的情况
                        }
                    )
                    .store(in: &self.cancellables)
            }
        }
        
        // 所有测试完成后生成报告
        dispatchGroup.notify(queue: .main) {
            self.resultTextView.text += "\n\n测试完成!\n"
            
            // 生成测试报告
            let report = WeakNetworkTestTool.generateTestReport(results: results, for: "弱网测试请求")
            self.resultTextView.text += "\n\(report)"
            
            // 恢复默认网络状态
            NetworkSimulation.simulateNetworkEnvironment(.excellentWifi)
            self.updateNetworkStatusDisplay()
        }
    }
}