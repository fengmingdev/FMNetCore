//
//  WeakNetworkMonitorViewController.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import UIKit
import Combine
import FMNetCore

class WeakNetworkMonitorViewController: UIViewController {
    
    private var tableView: UITableView!
    private var networkEvents: [NetworkEvent] = []
    private var cancellables = Set<AnyCancellable>()
    
    struct NetworkEvent {
        let timestamp: Date
        let status: NetworkStatus
        let description: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startMonitoring()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "网络状态监控"
        
        // 创建表格视图
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NetworkEventTableViewCell.self, forCellReuseIdentifier: "NetworkEventCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 添加清除按钮
        let clearButton = UIBarButtonItem(
            title: "清除",
            style: .plain,
            target: self,
            action: #selector(clearEvents)
        )
        navigationItem.rightBarButtonItem = clearButton
        
        // 设置约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func startMonitoring() {
        // 监听网络状态变化
        ReachabilityManager.shared.$networkStatus
            .sink { [weak self] status in
                guard let self = self else { return }
                
                let event = NetworkEvent(
                    timestamp: Date(),
                    status: status,
                    description: self.description(for: status)
                )
                
                // 在主线程更新UI
                DispatchQueue.main.async {
                    // 限制事件数量，只保留最新的100条记录
                    if self.networkEvents.count >= 100 {
                        self.networkEvents.removeLast()
                    }
                    
                    self.networkEvents.insert(event, at: 0)
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func description(for status: NetworkStatus) -> String {
        switch status {
        case .unreachable:
            return "网络不可达"
        case .wifi:
            return "连接到WiFi网络"
        case .cellular(let quality):
            let qualityText: String
            switch quality {
            case .excellent:
                qualityText = "优秀"
            case .good:
                qualityText = "良好"
            case .fair:
                qualityText = "一般"
            case .poor:
                qualityText = "较差（弱网）"
            }
            return "蜂窝网络 - 质量: \(qualityText)"
        }
    }
    
    @objc private func clearEvents() {
        networkEvents.removeAll()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension WeakNetworkMonitorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkEventCell", for: indexPath) as! NetworkEventTableViewCell
        let event = networkEvents[indexPath.row]
        cell.configure(with: event)
        return cell
    }
}

// MARK: - Network Event Table View Cell

class NetworkEventTableViewCell: UITableViewCell {
    
    private let timeLabel = UILabel()
    private let statusLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置样式
        selectionStyle = .none
        
        // 配置标签
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加到内容视图
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(descriptionLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with event: WeakNetworkMonitorViewController.NetworkEvent) {
        // 设置时间
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timeLabel.text = formatter.string(from: event.timestamp)
        
        // 设置状态
        statusLabel.text = statusText(for: event.status)
        statusLabel.textColor = statusColor(for: event.status)
        
        // 设置描述
        descriptionLabel.text = event.description
    }
    
    private func statusText(for status: NetworkStatus) -> String {
        switch status {
        case .unreachable:
            return "不可达"
        case .wifi:
            return "WiFi"
        case .cellular(let quality):
            switch quality {
            case .excellent: return "优秀"
            case .good: return "良好"
            case .fair: return "一般"
            case .poor: return "弱网"
            }
        }
    }
    
    private func statusColor(for status: NetworkStatus) -> UIColor {
        switch status {
        case .unreachable:
            return .systemRed
        case .wifi:
            return .systemGreen
        case .cellular(let quality):
            switch quality {
            case .excellent: return .systemGreen
            case .good: return .systemBlue
            case .fair: return .systemOrange
            case .poor: return .systemRed
            }
        }
    }
}