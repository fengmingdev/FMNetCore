//
//  SecurityExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import UIKit
import FMNetCore
import Combine

/// 演示安全特性的视图控制器
class SecurityExampleViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var cancellables = Set<AnyCancellable>() // 添加cancellables属性
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "安全特性示例"
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 14)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 创建按钮堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 添加配置证书锁定按钮
        let certificatePinningButton = UIButton(type: .system)
        certificatePinningButton.setTitle("配置证书锁定", for: .normal)
        certificatePinningButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        certificatePinningButton.addTarget(self, action: #selector(configureCertificatePinning), for: .touchUpInside)
        stackView.addArrangedSubview(certificatePinningButton)
        
        // 添加配置客户端证书认证按钮
        let clientCertificateButton = UIButton(type: .system)
        clientCertificateButton.setTitle("配置客户端证书认证", for: .normal)
        clientCertificateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        clientCertificateButton.addTarget(self, action: #selector(configureClientCertificate), for: .touchUpInside)
        stackView.addArrangedSubview(clientCertificateButton)
        
        // 添加发送安全请求按钮
        let secureRequestButton = UIButton(type: .system)
        secureRequestButton.setTitle("发送安全请求", for: .normal)
        secureRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        secureRequestButton.addTarget(self, action: #selector(sendSecureRequest), for: .touchUpInside)
        stackView.addArrangedSubview(secureRequestButton)
        
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
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            logTextView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func configureCertificatePinning() {
        log("配置证书锁定...")
        
        // 创建安全配置
        var securityConfig = SecurityConfig()
        securityConfig.enableCertificatePinning = true
        securityConfig.certificatePinningMode = .publicKey
        // 注意：在实际应用中，这里应该是实际的证书文件路径
        securityConfig.certificatePaths = ["path/to/certificate.cer"]
        
        // 配置安全管理器
        SecurityManager.shared.configure(with: securityConfig)
        
        // 更新网络配置
        var networkConfig = NetworkManager.shared.config
        networkConfig.securityConfig = securityConfig
        NetworkManager.shared.config = networkConfig
        
        log("证书锁定已配置")
    }
    
    @objc private func configureClientCertificate() {
        log("配置客户端证书认证...")
        
        // 创建安全配置
        var securityConfig = SecurityConfig()
        securityConfig.enableClientCertificateAuthentication = true
        // 注意：在实际应用中，这里应该是实际的证书文件路径和密码
        securityConfig.clientCertificatePath = "path/to/client-certificate.p12"
        securityConfig.clientCertificatePassword = "certificate-password"
        
        // 配置安全管理器
        SecurityManager.shared.configure(with: securityConfig)
        
        // 更新网络配置
        var networkConfig = NetworkManager.shared.config
        networkConfig.securityConfig = securityConfig
        NetworkManager.shared.config = networkConfig
        
        log("客户端证书认证已配置")
    }
    
    @objc private func sendSecureRequest() {
        log("发送安全请求...")
        
        // 创建一个普通的请求
        let request = GetUserRequest(userId: 1)
        
        log("使用当前安全配置发送请求")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    switch completion {
                    case .finished:
                        self?.log("安全请求完成")
                    case .failure(let error):
                        self?.log("安全请求失败: \(error.localizedDescription)")
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
