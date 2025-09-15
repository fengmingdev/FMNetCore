//
//  SmartRetryExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore
import Combine

/// 使用自定义重试策略的示例请求
struct SmartRetryExampleRequest: APIRequest {
    typealias Target = UserAPI
    
    let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func asTarget() -> UserAPI {
        return .getUser(id: userId)
    }
    
    // 使用自定义重试策略
    var retryStrategy: RetryStrategy? {
        // 创建一个自定义的重试策略，对于这个特定的请求
        return CustomRetryStrategy()
    }
    
    // 设置特定的重试次数
    var retryCount: Int? {
        return 5
    }
}

/// 自定义重试策略
class CustomRetryStrategy: RetryStrategy {
    func calculateRetryDelay(for attempt: Int, with error: NetworkError) -> TimeInterval {
        // 对于这个特定的请求，我们使用固定的延迟
        return 2.0
    }
    
    func shouldRetry(for attempt: Int, maxRetries: Int, with error: NetworkError) -> Bool {
        // 对于这个特定的请求，我们总是重试，直到达到最大次数
        return attempt < maxRetries
    }
}

/// 演示智能重试功能的视图控制器
class SmartRetryExampleViewController: UIViewController {
    
    public var cancellables = Set<AnyCancellable>()
    
    private var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "智能重试示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 14)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 添加开始按钮
        let startButton = UIButton(type: .system)
        startButton.setTitle("开始智能重试示例", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startExample), for: .touchUpInside)
        view.addSubview(startButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            clearButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            logTextView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func startExample() {
        log("开始智能重试示例...")
        
        // 创建一个使用自定义重试策略的请求
        let request = SmartRetryExampleRequest(userId: 1)
        
        log("发送请求，使用自定义重试策略（最大5次重试，每次2秒延迟）")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    switch completion {
                    case .finished:
                        self?.log("请求完成")
                    case .failure(let error):
                        self?.log("请求失败: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    self?.log("成功获取用户: \(user.name)")
                }
            )
            .store(in: &self.cancellables)
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
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
