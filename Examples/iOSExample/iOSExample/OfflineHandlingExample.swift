//
//  OfflineHandlingExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

/// 演示离线处理功能的视图控制器
class OfflineHandlingExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var statsLabel: UILabel!
    private var requestsTableView: UITableView!
    private var offlineRequests: [OfflineRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStats()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "离线处理示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建统计标签
        statsLabel = UILabel()
        statsLabel.font = UIFont.systemFont(ofSize: 14)
        statsLabel.textAlignment = .center
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsLabel)
        
        // 创建请求表格视图
        requestsTableView = UITableView()
        requestsTableView.translatesAutoresizingMaskIntoConstraints = false
        requestsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RequestCell")
        requestsTableView.delegate = self
        requestsTableView.dataSource = self
        view.addSubview(requestsTableView)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加模拟离线请求按钮
        let offlineRequestButton = UIButton(type: .system)
        offlineRequestButton.setTitle("模拟离线请求", for: .normal)
        offlineRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        offlineRequestButton.addTarget(self, action: #selector(simulateOfflineRequest), for: .touchUpInside)
        stackView.addArrangedSubview(offlineRequestButton)
        
        // 添加同步离线请求按钮
        let syncRequestsButton = UIButton(type: .system)
        syncRequestsButton.setTitle("同步离线请求", for: .normal)
        syncRequestsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        syncRequestsButton.addTarget(self, action: #selector(syncOfflineRequests), for: .touchUpInside)
        stackView.addArrangedSubview(syncRequestsButton)
        
        // 添加查看请求按钮
        let viewRequestsButton = UIButton(type: .system)
        viewRequestsButton.setTitle("查看离线请求", for: .normal)
        viewRequestsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        viewRequestsButton.addTarget(self, action: #selector(viewOfflineRequests), for: .touchUpInside)
        stackView.addArrangedSubview(viewRequestsButton)
        
        // 添加清除完成请求按钮
        let clearCompletedButton = UIButton(type: .system)
        clearCompletedButton.setTitle("清除已完成请求", for: .normal)
        clearCompletedButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        clearCompletedButton.addTarget(self, action: #selector(clearCompletedRequests), for: .touchUpInside)
        stackView.addArrangedSubview(clearCompletedButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statsLabel.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 10),
            statsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logTextView.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 80),
            
            requestsTableView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            requestsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            requestsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            requestsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func simulateOfflineRequest() {
        log("模拟离线请求...")
        
        // 创建一个用户请求
        let request = GetUserRequest(userId: Int.random(in: 1...10))
        
        // 将请求序列化为数据
        guard let requestData = try? JSONEncoder().encode(request) else {
            log("序列化请求失败")
            return
        }
        
        // 创建离线请求
        let currentEnvironment = EnvironmentManager.shared.getCurrentEnvironment()
        let baseURLString = EnvironmentManager.shared.getConfig(for: currentEnvironment)?.baseURL.absoluteString ?? "https://api.example.com"
        let offlineEnvironmentConfig = OfflineEnvironmentConfig(type: currentEnvironment, baseURL: baseURLString)
        
        let offlineRequest = OfflineRequest(
            requestData: requestData,
            status: .pending,
            targetEnvironment: offlineEnvironmentConfig
        )
        
        // 添加到离线请求管理器
        OfflineRequestManager.shared.addRequest(offlineRequest)
        
        log("离线请求已添加: \(offlineRequest.id)")
        updateStats()
    }
    
    @objc private func syncOfflineRequests() {
        log("开始同步离线请求...")
        
        // 触发同步
        OfflineRequestManager.shared.syncOfflineRequests()
        
        log("同步过程已启动")
        updateStats()
    }
    
    @objc private func viewOfflineRequests() {
        log("查看离线请求...")
        
        // 获取所有离线请求
        offlineRequests = OfflineRequestManager.shared.getAllRequests()
        
        // 更新UI
        logTextView.isHidden = true
        statsLabel.isHidden = true
        requestsTableView.isHidden = false
        requestsTableView.reloadData()
        
        log("显示 \(offlineRequests.count) 个离线请求")
    }
    
    @objc private func clearCompletedRequests() {
        log("清除已完成请求...")
        
        // 清除已完成的请求
        OfflineRequestManager.shared.removeCompletedRequests()
        
        log("已完成请求已清除")
        updateStats()
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
        logTextView.isHidden = false
        statsLabel.isHidden = false
        requestsTableView.isHidden = true
        offlineRequests.removeAll()
        requestsTableView.reloadData()
    }
    
    private func updateStats() {
        let stats = OfflineRequestManager.shared.getStats()
        let statsText = """
        离线请求统计:
        总数: \(stats.total) | 待处理: \(stats.pending) | 同步中: \(stats.syncing) | 已完成: \(stats.completed) | 失败: \(stats.failed)
        """
        statsLabel.text = statsText
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
            
            // 更新统计信息
            self.updateStats()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension OfflineHandlingExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offlineRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        let request = offlineRequests[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        ID: \(request.id.prefix(8))...
        状态: \(request.status.rawValue)
        时间: \(request.timestamp)
        重试次数: \(request.retryCount)
        错误: \(request.errorMessage ?? "无")
        环境: \(request.targetEnvironment.type.rawValue)
        """
        
        // 根据状态设置背景颜色
        switch request.status {
        case .pending:
            cell.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)
        case .syncing:
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        case .completed:
            cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        case .failed:
            cell.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}