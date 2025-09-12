//
//  NetworkLogViewController.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import UIKit

class NetworkLogViewController: UIViewController {
    
    private var tableView: UITableView!
    private var logEntries: [NetworkLogger.LogEntry] = []
    private var filteredLogEntries: [NetworkLogger.LogEntry] = []
    private var logLevelFilter: NetworkLogger.LogLevel = .verbose
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogs()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "网络日志"
        
        // 创建表格视图
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogEntryTableViewCell.self, forCellReuseIdentifier: "LogEntryCell")
        view.addSubview(tableView)
        
        // 创建工具栏
        setupToolbar()
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44))
        
        let clearButton = UIBarButtonItem(title: "清除", style: .plain, target: self, action: #selector(clearLogs))
        let refreshButton = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(refreshLogs))
        let filterButton = UIBarButtonItem(title: "过滤", style: .plain, target: self, action: #selector(showFilterOptions))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [clearButton, flexibleSpace, refreshButton, flexibleSpace, filterButton]
        view.addSubview(toolbar)
        
        // 调整表格视图大小
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 44)
    }
    
    private func loadLogs() {
        logEntries = NetworkLogger.shared.getLogEntries()
        filterLogs()
        tableView.reloadData()
    }
    
    private func filterLogs() {
        filteredLogEntries = logEntries.filter { $0.level.rawValue >= logLevelFilter.rawValue }
    }
    
    @objc private func clearLogs() {
        NetworkLogger.shared.clearLogs()
        loadLogs()
    }
    
    @objc private func refreshLogs() {
        loadLogs()
    }
    
    @objc private func showFilterOptions() {
        let alertController = UIAlertController(title: "日志级别过滤", message: nil, preferredStyle: .actionSheet)
        
        for level in NetworkLogger.LogLevel.allCases {
            let action = UIAlertAction(title: level.description, style: .default) { _ in
                self.logLevelFilter = level
                self.filterLogs()
                self.tableView.reloadData()
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension NetworkLogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogEntryCell", for: indexPath) as! LogEntryTableViewCell
        let logEntry = filteredLogEntries[indexPath.row]
        cell.configure(with: logEntry)
        return cell
    }
}

// MARK: - Log Entry Table View Cell

class LogEntryTableViewCell: UITableViewCell {
    
    private let levelLabel = UILabel()
    private let timestampLabel = UILabel()
    private let messageLabel = UILabel()
    private let detailLabel = UILabel()
    
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
        levelLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timestampLabel.font = UIFont.systemFont(ofSize: 10)
        timestampLabel.textColor = .secondaryLabel
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加到内容视图
        contentView.addSubview(levelLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(detailLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            levelLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            levelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            levelLabel.widthAnchor.constraint(equalToConstant: 60),
            
            timestampLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timestampLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 8),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            detailLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with logEntry: NetworkLogger.LogEntry) {
        // 设置级别标签
        levelLabel.text = logEntry.level.description
        levelLabel.textColor = color(for: logEntry.level)
        
        // 设置时间戳
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        timestampLabel.text = formatter.string(from: logEntry.timestamp)
        
        // 设置消息
        messageLabel.text = logEntry.message
        
        // 设置详细信息
        var detailText = ""
        
        if let requestInfo = logEntry.requestInfo {
            detailText += "请求: \(requestInfo.method) \(requestInfo.url)\n"
        }
        
        if let responseInfo = logEntry.responseInfo {
            detailText += "响应: 状态码 \(responseInfo.statusCode) (耗时: \(String(format: "%.2f", responseInfo.duration * 1000))ms)\n"
        }
        
        detailLabel.text = detailText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 根据是否有详细信息调整高度
        detailLabel.isHidden = detailText.isEmpty
    }
    
    private func color(for level: NetworkLogger.LogLevel) -> UIColor {
        switch level {
        case .verbose:
            return .systemGray
        case .debug:
            return .systemBlue
        case .info:
            return .systemGreen
        case .warning:
            return .systemOrange
        case .error:
            return .systemRed
        case .none:
            return .systemGray
        }
    }
}