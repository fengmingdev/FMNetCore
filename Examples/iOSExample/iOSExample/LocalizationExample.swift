//
//  LocalizationExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

/// 演示国际化功能的视图控制器
class LocalizationExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var languageSegmentedControl: UISegmentedControl!
    private var errorLabel: UILabel!
    private var logLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDisplay()
        
        // 监听语言变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "国际化示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建语言选择控件
        languageSegmentedControl = UISegmentedControl(items: ["English", "中文"])
        languageSegmentedControl.selectedSegmentIndex = Locale.current.languageCode == "zh" ? 1 : 0
        languageSegmentedControl.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
        languageSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(languageSegmentedControl)
        
        // 创建错误标签
        errorLabel = UILabel()
        errorLabel.font = UIFont.systemFont(ofSize: 16)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // 创建日志标签
        logLabel = UILabel()
        logLabel.font = UIFont.systemFont(ofSize: 16)
        logLabel.textAlignment = .center
        logLabel.numberOfLines = 0
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logLabel)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加显示错误按钮
        let showErrorButton = UIButton(type: .system)
        showErrorButton.setTitle("显示错误消息", for: .normal)
        showErrorButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        showErrorButton.addTarget(self, action: #selector(showErrorMessages), for: .touchUpInside)
        stackView.addArrangedSubview(showErrorButton)
        
        // 添加显示日志按钮
        let showLogButton = UIButton(type: .system)
        showLogButton.setTitle("显示日志消息", for: .normal)
        showLogButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        showLogButton.addTarget(self, action: #selector(showLogMessages), for: .touchUpInside)
        stackView.addArrangedSubview(showLogButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            languageSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            languageSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            languageSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            stackView.topAnchor.constraint(equalTo: languageSegmentedControl.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10),
            logLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logTextView.topAnchor.constraint(equalTo: logLabel.bottomAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func languageChanged(_ sender: Any? = nil) {
        let languageCode = languageSegmentedControl.selectedSegmentIndex == 0 ? "en" : "zh-Hans"
        LocalizationManager.shared.switchLanguage(to: languageCode)
        log("语言已切换到: \(languageCode)")
        updateDisplay()
    }
    
    @objc private func showErrorMessages() {
        log("显示错误消息...")
        
        // 创建各种网络错误并显示本地化消息
        let errors: [NetworkError] = [
            .invalidURL,
            .noData,
            .serverError(500),
            .httpError(code: 404),
            .timeout,
            .networkUnreachable,
            .weakNetworkNotAllowed
        ]
        
        for error in errors {
            log("错误: \(error.localizedDescription)")
        }
    }
    
    @objc private func showLogMessages() {
        log("显示日志消息...")
        
        // 显示一些本地化日志消息
        let messages = [
            LocalizationManager.shared.localizedString(for: LocalizationKey.requestSending.rawValue),
            LocalizationManager.shared.localizedString(for: LocalizationKey.requestSuccess.rawValue),
            LocalizationManager.shared.localizedString(for: LocalizationKey.requestFailure.rawValue),
            LocalizationManager.shared.localizedString(for: "loading.indicator.loading", defaultValue: "Loading..."),
            LocalizationManager.shared.localizedString(for: "cache.hit", defaultValue: "Cache hit")
        ]
        
        for message in messages {
            log("消息: \(message)")
        }
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
    }
    
    private func updateDisplay() {
        // 更新错误标签
        errorLabel.text = """
        无效URL错误: \(NetworkError.invalidURL.localizedDescription)
        超时错误: \(NetworkError.timeout.localizedDescription)
        网络不可达错误: \(NetworkError.networkUnreachable.localizedDescription)
        """
        
        // 更新日志标签
        logLabel.text = """
        请求发送: \(LocalizationManager.shared.localizedString(for: LocalizationKey.requestSending.rawValue))
        请求成功: \(LocalizationManager.shared.localizedString(for: LocalizationKey.requestSuccess.rawValue))
        加载中: \(LocalizationManager.shared.localizedString(for: "loading.indicator.loading", defaultValue: "Loading..."))
        """
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
    
    @objc private func languageChanged() {
        log("语言已更改")
        updateDisplay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}