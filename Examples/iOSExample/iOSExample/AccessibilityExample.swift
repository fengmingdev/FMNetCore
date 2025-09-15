//
//  AccessibilityExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore

/// 演示可访问性功能的视图控制器
class AccessibilityExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var accessibilitySwitch: UISwitch!
    private var fontSizeSlider: UISlider!
    private var fontSizeLabel: UILabel!
    private var loadingButton: UIButton!
    private var voiceOverLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateAccessibilityStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "可访问性示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.isAccessibilityElement = true
        logTextView.accessibilityLabel = "日志输出区域"
        logTextView.accessibilityHint = "显示网络请求和可访问性相关的日志信息"
        view.addSubview(logTextView)
        
        // 创建可访问性开关
        let accessibilityStack = UIStackView()
        accessibilityStack.axis = .horizontal
        accessibilityStack.spacing = 10
        accessibilityStack.alignment = .center
        accessibilityStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(accessibilityStack)
        
        let accessibilityLabel = UILabel()
        accessibilityLabel.text = "启用可访问性:"
        accessibilityLabel.font = UIFont.systemFont(ofSize: 16)
        accessibilityLabel.isAccessibilityElement = true
        accessibilityLabel.accessibilityLabel = "可访问性开关标签"
        accessibilityStack.addArrangedSubview(accessibilityLabel)
        
        accessibilitySwitch = UISwitch()
        accessibilitySwitch.isOn = UIAccessibility.isVoiceOverRunning
        accessibilitySwitch.addTarget(self, action: #selector(accessibilitySwitchChanged), for: .valueChanged)
        accessibilitySwitch.isAccessibilityElement = true
        accessibilitySwitch.accessibilityLabel = "可访问性开关"
        accessibilitySwitch.accessibilityHint = "打开或关闭可访问性支持"
        accessibilityStack.addArrangedSubview(accessibilitySwitch)
        
        // 创建字体大小控制
        let fontSizeStack = UIStackView()
        fontSizeStack.axis = .horizontal
        fontSizeStack.spacing = 10
        fontSizeStack.alignment = .center
        fontSizeStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fontSizeStack)
        
        let fontSizeLabelTitle = UILabel()
        fontSizeLabelTitle.text = "字体大小:"
        fontSizeLabelTitle.font = UIFont.systemFont(ofSize: 16)
        fontSizeLabelTitle.isAccessibilityElement = true
        fontSizeLabelTitle.accessibilityLabel = "字体大小控制标签"
        fontSizeStack.addArrangedSubview(fontSizeLabelTitle)
        
        fontSizeSlider = UISlider()
        fontSizeSlider.minimumValue = 10
        fontSizeSlider.maximumValue = 30
        fontSizeSlider.value = 16
        fontSizeSlider.addTarget(self, action: #selector(fontSizeSliderChanged), for: .valueChanged)
        fontSizeSlider.isAccessibilityElement = true
        fontSizeSlider.accessibilityLabel = "字体大小滑块"
        fontSizeSlider.accessibilityHint = "调整界面字体大小"
        fontSizeSlider.accessibilityValue = "16点"
        fontSizeStack.addArrangedSubview(fontSizeSlider)
        
        fontSizeLabel = UILabel()
        fontSizeLabel.text = "16pt"
        fontSizeLabel.font = UIFont.systemFont(ofSize: 16)
        fontSizeLabel.isAccessibilityElement = true
        fontSizeLabel.accessibilityLabel = "当前字体大小"
        fontSizeStack.addArrangedSubview(fontSizeLabel)
        
        // 创建加载指示器按钮
        loadingButton = UIButton(type: .system)
        loadingButton.setTitle("显示加载指示器", for: .normal)
        loadingButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        loadingButton.addTarget(self, action: #selector(showLoadingIndicator), for: .touchUpInside)
        loadingButton.translatesAutoresizingMaskIntoConstraints = false
        loadingButton.isAccessibilityElement = true
        loadingButton.accessibilityLabel = "加载指示器按钮"
        loadingButton.accessibilityHint = "点击显示可访问的加载指示器"
        view.addSubview(loadingButton)
        
        // 创建VoiceOver状态标签
        voiceOverLabel = UILabel()
        voiceOverLabel.font = UIFont.systemFont(ofSize: 16)
        voiceOverLabel.textAlignment = .center
        voiceOverLabel.numberOfLines = 0
        voiceOverLabel.isAccessibilityElement = true
        voiceOverLabel.accessibilityLabel = "VoiceOver状态"
        view.addSubview(voiceOverLabel)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加测试VoiceOver按钮
        let testVoiceOverButton = UIButton(type: .system)
        testVoiceOverButton.setTitle("测试VoiceOver", for: .normal)
        testVoiceOverButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        testVoiceOverButton.addTarget(self, action: #selector(testVoiceOver), for: .touchUpInside)
        testVoiceOverButton.isAccessibilityElement = true
        testVoiceOverButton.accessibilityLabel = "测试VoiceOver按钮"
        testVoiceOverButton.accessibilityHint = "测试VoiceOver屏幕阅读器功能"
        stackView.addArrangedSubview(testVoiceOverButton)
        
        // 添加清除日志按钮
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除日志", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        clearButton.isAccessibilityElement = true
        clearButton.accessibilityLabel = "清除日志按钮"
        clearButton.accessibilityHint = "清除日志输出区域的内容"
        view.addSubview(clearButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            accessibilityStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            accessibilityStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accessibilityStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fontSizeStack.topAnchor.constraint(equalTo: accessibilityStack.bottomAnchor, constant: 20),
            fontSizeStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontSizeStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loadingButton.topAnchor.constraint(equalTo: fontSizeStack.bottomAnchor, constant: 20),
            loadingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: loadingButton.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            voiceOverLabel.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            voiceOverLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            voiceOverLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logTextView.topAnchor.constraint(equalTo: voiceOverLabel.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func accessibilitySwitchChanged() {
        log("可访问性开关状态已更改: \(accessibilitySwitch.isOn)")
        updateAccessibilityStatus()
    }
    
    @objc private func fontSizeSliderChanged() {
        let fontSize = fontSizeSlider.value
        fontSizeLabel.text = "\(Int(fontSize))pt"
        fontSizeSlider.accessibilityValue = "\(Int(fontSize))点"
        
        // 更新日志文本视图的字体大小
        logTextView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        
        log("字体大小已调整为: \(Int(fontSize))pt")
    }
    
    @objc private func showLoadingIndicator() {
        log("显示加载指示器...")
        
        // 显示加载指示器
        let taskId = LoadingIndicatorManager.shared.showLoading()
        
        // 3秒后隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            LoadingIndicatorManager.shared.hideLoading(for: taskId)
            self.log("加载指示器已隐藏")
        }
    }
    
    @objc private func testVoiceOver() {
        log("测试VoiceOver功能...")
        
        // 检查VoiceOver是否运行
        if UIAccessibility.isVoiceOverRunning {
            log("VoiceOver正在运行")
            
            // 使用VoiceOver朗读测试文本
            let testText = "这是一个VoiceOver测试文本，用于验证可访问性功能是否正常工作。"
            UIAccessibility.post(notification: .announcement, argument: testText)
        } else {
            log("VoiceOver未运行")
        }
    }
    
    @objc private func clearLogs() {
        logTextView.text = ""
    }
    
    private func updateAccessibilityStatus() {
        let isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        voiceOverLabel.text = "VoiceOver状态: \(isVoiceOverRunning ? "运行中" : "未运行")"
        voiceOverLabel.accessibilityValue = isVoiceOverRunning ? "VoiceOver正在运行" : "VoiceOver未运行"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAccessibilityStatus()
    }
}