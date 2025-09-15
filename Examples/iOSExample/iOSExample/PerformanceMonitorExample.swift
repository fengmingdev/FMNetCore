//
//  PerformanceMonitorExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore
import Combine

/// 演示性能监控功能的视图控制器
class PerformanceMonitorExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var metricsTableView: UITableView!
    private var metrics: [PerformanceMetrics] = []
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "性能监控示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建指标表格视图
        metricsTableView = UITableView()
        metricsTableView.translatesAutoresizingMaskIntoConstraints = false
        metricsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MetricCell")
        metricsTableView.delegate = self
        metricsTableView.dataSource = self
        view.addSubview(metricsTableView)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加配置性能监控按钮
        let configureButton = UIButton(type: .system)
        configureButton.setTitle("配置性能监控", for: .normal)
        configureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        configureButton.addTarget(self, action: #selector(configurePerformanceMonitoring), for: .touchUpInside)
        stackView.addArrangedSubview(configureButton)
        
        // 添加发送请求按钮
        let sendRequestButton = UIButton(type: .system)
        sendRequestButton.setTitle("发送网络请求", for: .normal)
        sendRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        sendRequestButton.addTarget(self, action: #selector(sendNetworkRequest), for: .touchUpInside)
        stackView.addArrangedSubview(sendRequestButton)
        
        // 添加查看指标按钮
        let viewMetricsButton = UIButton(type: .system)
        viewMetricsButton.setTitle("查看性能指标", for: .normal)
        viewMetricsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        viewMetricsButton.addTarget(self, action: #selector(viewPerformanceMetrics), for: .touchUpInside)
        stackView.addArrangedSubview(viewMetricsButton)
        
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
            
            logTextView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 100),
            
            metricsTableView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            metricsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metricsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metricsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        metricsTableView.isHidden = true
    }
    
    @objc private func configurePerformanceMonitoring() {
        log("配置性能监控...")
        
        // 创建性能监控配置
        var config = PerformanceMonitorConfig()
        config.enabled = true
        config.detailedMetrics = true
        config.logLevel = .verbose
        config.performanceThreshold = 2000 // 2秒阈值
        config.enableMemoryMonitoring = true
        config.memoryThreshold = 50 // 50MB阈值
        config.enableNetworkTrafficMonitoring = true
        config.networkTrafficThreshold = 5 // 5MB阈值
        
        // 配置性能监控管理器
        PerformanceMonitor.shared.configure(with: config)
        
        log("性能监控已配置")
    }
    
    @objc private func sendNetworkRequest() {
        log("发送网络请求...")
        
        // 创建一个普通的请求
        let request = GetUserRequest(userId: 1)
        
        log("开始发送请求")
        
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
        log("请求已发送")
    }
    
    @objc private func viewPerformanceMetrics() {
        log("查看性能指标...")
        
        // 获取所有性能指标
        metrics = PerformanceMonitor.shared.getAllMetrics()
        
        // 更新UI
        logTextView.isHidden = true
        metricsTableView.isHidden = false
        metricsTableView.reloadData()
        
        log("显示 \(metrics.count) 个性能指标")
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
        logTextView.isHidden = false
        metricsTableView.isHidden = true
        metrics.removeAll()
        metricsTableView.reloadData()
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

// MARK: - UITableViewDataSource & UITableViewDelegate

extension PerformanceMonitorExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath)
        let metric = metrics[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        ID: \(metric.requestId.prefix(8))...
        URL: \(metric.url)
        方法: \(metric.method)
        耗时: \(String(format: "%.2f", metric.duration))ms
        内存: \(String(format: "%.2f", metric.memoryUsage))MB
        流量: \(String(format: "%.2f", metric.networkTraffic))MB
        超阈值: \(metric.isOverThreshold ? "是" : "否")
        """
        
        // 如果超阈值，设置警告颜色
        if metric.isOverThreshold {
            cell.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
        } else {
            cell.backgroundColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
