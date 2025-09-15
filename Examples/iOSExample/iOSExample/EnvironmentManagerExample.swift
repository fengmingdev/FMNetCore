//
//  EnvironmentManagerExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

/// 演示多环境配置管理功能的视图控制器
class EnvironmentManagerExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var environmentSegmentedControl: UISegmentedControl!
    private var configTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateConfigDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "环境配置管理示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建环境选择控件
        environmentSegmentedControl = UISegmentedControl(items: ["开发", "测试", "预发布", "生产"])
        environmentSegmentedControl.selectedSegmentIndex = 0
        environmentSegmentedControl.addTarget(self, action: #selector(environmentChanged), for: .valueChanged)
        environmentSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(environmentSegmentedControl)
        
        // 创建配置显示文本视图
        configTextView = UITextView()
        configTextView.isEditable = false
        configTextView.backgroundColor = .secondarySystemBackground
        configTextView.font = UIFont.systemFont(ofSize: 12)
        configTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(configTextView)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加切换环境按钮
        let switchEnvironmentButton = UIButton(type: .system)
        switchEnvironmentButton.setTitle("切换到当前环境", for: .normal)
        switchEnvironmentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        switchEnvironmentButton.addTarget(self, action: #selector(switchToCurrentEnvironment), for: .touchUpInside)
        stackView.addArrangedSubview(switchEnvironmentButton)
        
        // 添加自定义配置按钮
        let customConfigButton = UIButton(type: .system)
        customConfigButton.setTitle("添加自定义配置", for: .normal)
        customConfigButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        customConfigButton.addTarget(self, action: #selector(addCustomConfig), for: .touchUpInside)
        stackView.addArrangedSubview(customConfigButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            environmentSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            environmentSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            environmentSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            stackView.topAnchor.constraint(equalTo: environmentSegmentedControl.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            logTextView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 100),
            
            configTextView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            configTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            configTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            configTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func environmentChanged() {
        log("环境选择已更改")
        updateConfigDisplay()
    }
    
    @objc private func switchToCurrentEnvironment() {
        let environments: [EnvironmentType] = [.development, .testing, .staging, .production]
        let selectedEnvironment = environments[environmentSegmentedControl.selectedSegmentIndex]
        
        log("切换到 \(selectedEnvironment.rawValue) 环境...")
        
        // 设置当前环境
        EnvironmentManager.shared.setCurrentEnvironment(selectedEnvironment)
        
        log("已切换到 \(selectedEnvironment.rawValue) 环境")
        updateConfigDisplay()
    }
    
    @objc private func addCustomConfig() {
        log("添加自定义配置...")
        
        // 创建自定义环境配置
        guard let customURL = URL(string: "https://custom.api.example.com") else {
            log("无效的自定义URL")
            return
        }
        
        let customConfig = EnvironmentConfig(
            type: .development,
            baseURL: customURL,
            apiVersion: "v2",
            timeoutInterval: 25.0,
            enableLogging: true,
            logLevel: .debug,
            maxRetryCount: 5,
            enableCache: false,
            customConfig: ["custom": true, "featureFlag": "enabled"]
        )
        
        // 添加配置
        EnvironmentManager.shared.addConfig(customConfig, for: .development)
        
        log("自定义配置已添加")
        updateConfigDisplay()
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
    }
    
    private func updateConfigDisplay() {
        let environments: [EnvironmentType] = [.development, .testing, .staging, .production]
        let selectedEnvironment = environments[environmentSegmentedControl.selectedSegmentIndex]
        
        if let config = EnvironmentManager.shared.getConfig(for: selectedEnvironment) {
            let configText = """
            环境类型: \(config.type.rawValue)
            基础URL: \(config.baseURL.absoluteString)
            API版本: \(config.apiVersion)
            超时时间: \(config.timeoutInterval)秒
            启用日志: \(config.enableLogging)
            日志级别: \(config.logLevel.description)
            最大重试次数: \(config.maxRetryCount)
            启用缓存: \(config.enableCache)
            自定义配置: \(config.customConfig)
            """
            
            configTextView.text = configText
        } else {
            configTextView.text = "未找到配置"
        }
    }
    
    private func log(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .none,
                timeStyle: .medium
            )
            let formattedMessage = "[\(timestamp)] \(message)\n"
            
            self.logTextView.text += formattedMessage
            self.logTextView.scrollRangeToVisible(NSRange(location: self.logTextView.text.count - 1, length: 1))
        }
    }
}