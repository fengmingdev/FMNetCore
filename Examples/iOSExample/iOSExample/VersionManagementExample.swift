//
//  VersionManagementExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

/// 演示向后兼容性功能的视图控制器
class VersionManagementExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var versionSegmentedControl: UISegmentedControl!
    private var strategySegmentedControl: UISegmentedControl!
    private var reportTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateReport()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "版本管理示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建版本选择控件
        versionSegmentedControl = UISegmentedControl(items: ["v1", "v2", "v3"])
        versionSegmentedControl.selectedSegmentIndex = 0
        versionSegmentedControl.addTarget(self, action: #selector(versionChanged), for: .valueChanged)
        versionSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionSegmentedControl)
        
        // 创建策略选择控件
        strategySegmentedControl = UISegmentedControl(items: ["严格", "宽松", "自动"])
        strategySegmentedControl.selectedSegmentIndex = 2
        strategySegmentedControl.addTarget(self, action: #selector(strategyChanged), for: .valueChanged)
        strategySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(strategySegmentedControl)
        
        // 创建报告文本视图
        reportTextView = UITextView()
        reportTextView.isEditable = false
        reportTextView.backgroundColor = .secondarySystemBackground
        reportTextView.font = UIFont.systemFont(ofSize: 12)
        reportTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reportTextView)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加设置当前版本按钮
        let setCurrentVersionButton = UIButton(type: .system)
        setCurrentVersionButton.setTitle("设置当前版本", for: .normal)
        setCurrentVersionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        setCurrentVersionButton.addTarget(self, action: #selector(setCurrentVersion), for: .touchUpInside)
        stackView.addArrangedSubview(setCurrentVersionButton)
        
        // 添加废弃版本按钮
        let deprecateVersionButton = UIButton(type: .system)
        deprecateVersionButton.setTitle("废弃当前版本", for: .normal)
        deprecateVersionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        deprecateVersionButton.addTarget(self, action: #selector(deprecateCurrentVersion), for: .touchUpInside)
        stackView.addArrangedSubview(deprecateVersionButton)
        
        // 添加获取端点URL按钮
        let getEndpointButton = UIButton(type: .system)
        getEndpointButton.setTitle("获取API端点URL", for: .normal)
        getEndpointButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        getEndpointButton.addTarget(self, action: #selector(getAPIEndpoint), for: .touchUpInside)
        stackView.addArrangedSubview(getEndpointButton)
        
        // 添加查看报告按钮
        let viewReportButton = UIButton(type: .system)
        viewReportButton.setTitle("查看兼容性报告", for: .normal)
        viewReportButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        viewReportButton.addTarget(self, action: #selector(viewCompatibilityReport), for: .touchUpInside)
        stackView.addArrangedSubview(viewReportButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            versionSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            versionSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            strategySegmentedControl.topAnchor.constraint(equalTo: versionSegmentedControl.bottomAnchor, constant: 20),
            strategySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            strategySegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            stackView.topAnchor.constraint(equalTo: strategySegmentedControl.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            logTextView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 100),
            
            reportTextView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            reportTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func versionChanged() {
        log("版本选择已更改")
    }
    
    @objc private func strategyChanged() {
        log("策略选择已更改")
    }
    
    @objc private func setCurrentVersion() {
        let versions: [APIVersion] = [.v1, .v2, .v3]
        let selectedVersion = versions[versionSegmentedControl.selectedSegmentIndex]
        
        log("设置当前API版本为: \(selectedVersion.rawValue)")
        
        // 设置当前API版本
        VersionManager.shared.setCurrentAPIVersion(selectedVersion)
        
        log("当前API版本已设置为: \(selectedVersion.rawValue)")
        updateReport()
    }
    
    @objc private func deprecateCurrentVersion() {
        let versions: [APIVersion] = [.v1, .v2, .v3]
        let selectedVersion = versions[versionSegmentedControl.selectedSegmentIndex]
        
        log("废弃API版本: \(selectedVersion.rawValue)")
        
        // 废弃当前版本
        VersionManager.shared.deprecateVersion(selectedVersion)
        
        log("API版本 \(selectedVersion.rawValue) 已标记为废弃")
        updateReport()
    }
    
    @objc private func getAPIEndpoint() {
        let versions: [APIVersion] = [.v1, .v2, .v3]
        let selectedVersion = versions[versionSegmentedControl.selectedSegmentIndex]
        let strategies: [VersionCompatibilityStrategy] = [.strict, .lenient, .automatic]
        let selectedStrategy = strategies[strategySegmentedControl.selectedSegmentIndex]
        
        log("获取API端点URL...")
        
        // 设置兼容性策略
        VersionManager.shared.setCompatibilityStrategy(selectedStrategy)
        
        // 获取API端点URL
        let endpoint = VersionManager.shared.getAPIEndpoint(basePath: "https://api.example.com/", version: selectedVersion)
        
        log("API端点URL: \(endpoint)")
    }
    
    @objc private func viewCompatibilityReport() {
        log("查看兼容性报告...")
        updateReport()
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
    }
    
    private func updateReport() {
        let report = VersionManager.shared.getCompatibilityReport()
        
        let reportText = """
        版本兼容性报告:
        当前版本: \(report.currentVersion.rawValue)
        兼容性策略: \(getStrategyDescription(report.compatibilityStrategy))
        已废弃API: \(report.deprecatedAPIs.isEmpty ? "无" : report.deprecatedAPIs.joined(separator: ", "))
        已废弃版本: \(report.deprecatedVersions.isEmpty ? "无" : report.deprecatedVersions.map { $0.rawValue }.joined(separator: ", "))
        """
        
        reportTextView.text = reportText
    }
    
    private func getStrategyDescription(_ strategy: VersionCompatibilityStrategy) -> String {
        switch strategy {
        case .strict:
            return "严格模式"
        case .lenient:
            return "宽松模式"
        case .automatic:
            return "自动模式"
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