//
//  NetworkExamplesViewController.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import UIKit
import FMNetCore
import Combine

class NetworkExamplesViewController: UIViewController {
    
    private var tableView: UITableView!
    private var examples: [Example] = []
    private var cancellables = Set<AnyCancellable>()
    
    struct Example {
        let title: String
        let description: String
        let action: () -> Void
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExamples()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "网络框架示例"
        
        // 创建表格视图
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExampleCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 添加导航栏按钮
        let clearCacheButton = UIBarButtonItem(
            title: "清除缓存",
            style: .plain,
            target: self,
            action: #selector(clearCacheTapped)
        )
        
        let showLogsButton = UIBarButtonItem(
            title: "查看日志",
            style: .plain,
            target: self,
            action: #selector(showLogsTapped)
        )
        
        let showStatsButton = UIBarButtonItem(
            title: "缓存统计",
            style: .plain,
            target: self,
            action: #selector(showStatsTapped)
        )
        
        navigationItem.rightBarButtonItems = [showStatsButton, showLogsButton, clearCacheButton]
        
        // 设置约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupExamples() {
        examples = [
            Example(
                title: "单个请求（带缓存）",
                description: "演示使用缓存获取单个用户信息",
                action: fetchUserWithCache
            ),
            Example(
                title: "单个请求（无缓存）",
                description: "演示不使用缓存获取单个用户信息",
                action: fetchUserWithoutCache
            ),
            Example(
                title: "组合请求（带缓存）",
                description: "演示使用缓存并行获取用户和帖子信息",
                action: fetchUserAndPostsWithCache
            ),
            Example(
                title: "组合请求（无缓存）",
                description: "演示不使用缓存并行获取用户和帖子信息",
                action: fetchUserAndPostsWithoutCache
            ),
            Example(
                title: "三个请求组合",
                description: "演示并行获取用户、帖子和用户列表",
                action: fetchUserPostAndUsers
            ),
            Example(
                title: "错误处理演示",
                description: "演示网络错误处理机制",
                action: demonstrateErrorHandling
            ),
            Example(
                title: "弱网环境模拟",
                description: "演示弱网环境下的请求处理",
                action: simulateWeakNetwork
            ),
            Example(
                title: "弱网环境请求（允许）",
                description: "在弱网环境下允许请求的示例",
                action: weakNetworkRequestAllowed
            ),
            Example(
                title: "弱网环境请求（不允许）",
                description: "在弱网环境下拒绝请求的示例",
                action: weakNetworkRequestNotAllowed
            ),
            Example(
                title: "弱网环境测试",
                description: "交互式弱网环境测试",
                action: showWeakNetworkTest
            ),
            Example(
                title: "弱网环境监控",
                description: "实时监控网络状态变化",
                action: showWeakNetworkMonitor
            ),
            Example(
                title: "弱网使用示例",
                description: "展示弱网环境下的各种使用场景",
                action: showWeakNetworkUsageExamples
            ),
            Example(
                title: "动态Base URL示例",
                description: "演示如何使用动态Base URL",
                action: demonstrateDynamicBaseURL
            ),
            Example(
                title: "代理配置示例",
                description: "演示如何配置网络代理",
                action: demonstrateProxyConfig
            ),
            Example(
                title: "SSL证书配置示例",
                description: "演示如何配置SSL证书",
                action: demonstrateSSLCertificateConfig
            ),
            Example(
                title: "重定向处理示例",
                description: "演示如何处理HTTP重定向",
                action: demonstrateRedirectHandling
            ),
            Example(
                title: "自定义加载指示器",
                description: "演示如何自定义加载指示器样式",
                action: demonstrateCustomLoadingIndicator
            ),
            Example(
                title: "Toast-Swift加载指示器",
                description: "演示使用Toast-Swift库的自定义加载指示器",
                action: demonstrateToastSwiftLoadingIndicator
            )
        ]
    }
    
    @objc private func clearCacheTapped() {
        CacheManager.shared.clearAllCache()
        showAlert(title: "缓存已清除", message: "所有缓存数据已被清除")
    }
    
    @objc private func showLogsTapped() {
        let logViewController = NetworkLogViewController()
        navigationController?.pushViewController(logViewController, animated: true)
    }
    
    @objc private func showStatsTapped() {
        let statsViewController = CacheStatsViewController()
        navigationController?.pushViewController(statsViewController, animated: true)
    }
    
    @objc private func showWeakNetworkTest() {
        let weakNetworkTestViewController = WeakNetworkTestViewController()
        navigationController?.pushViewController(weakNetworkTestViewController, animated: true)
    }
    
    @objc private func showWeakNetworkMonitor() {
        let weakNetworkMonitorViewController = WeakNetworkMonitorViewController()
        navigationController?.pushViewController(weakNetworkMonitorViewController, animated: true)
    }
    
    @objc private func showWeakNetworkUsageExamples() {
        // 创建一个简单的展示页面来说明弱网使用示例
        let exampleViewController = UIViewController()
        exampleViewController.title = "弱网使用示例"
        exampleViewController.view.backgroundColor = .systemBackground
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.text = """
        弱网环境使用示例:
        
        1. 基本的弱网环境处理
           - 定义允许/不允许在弱网环境下请求的API
           - 根据allowsWeakNetwork属性控制请求行为
        
        2. 自适应请求策略
           - 根据网络质量调整超时时间和重试策略
           - 动态调整请求参数
        
        3. 数据预加载
           - 在弱网环境下预加载缓存数据
           - 减少用户等待时间
        
        4. 弱网监控
           - 实时监控网络状态变化
           - 在检测到弱网时通知用户
        
        5. 错误恢复机制
           - 在弱网环境下增加重试次数
           - 提供用户友好的错误提示
        
        详细代码请查看 WeakNetworkUsageExample.swift 文件。
        """
        
        exampleViewController.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: exampleViewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: exampleViewController.view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: exampleViewController.view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: exampleViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        navigationController?.pushViewController(exampleViewController, animated: true)
    }
    
    // MARK: - 新功能示例方法
    
    /// 动态Base URL示例
    private func demonstrateDynamicBaseURL() {
        // 设置动态Base URL
        if let customURL = URL(string: "https://jsonplaceholder.typicode.com") {
            DynamicBaseURLManager.shared.setDynamicBaseURL(customURL, for: "userAPI")
        }
        
        let request = GetDynamicUserRequest(userId: 1)
        
        showAlert(title: "动态Base URL", message: "正在使用动态Base URL获取用户信息...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n邮箱: \(user.email)\n使用动态Base URL获取")
                    }
                    
                    // 清除动态Base URL
                    DynamicBaseURLManager.shared.removeDynamicBaseURL(for: "userAPI")
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 代理配置示例
    private func demonstrateProxyConfig() {
        // 创建代理配置
        let proxyConfig = ProxyConfig(
            host: "127.0.0.1",
            port: 8080,
            httpEnabled: true,
            httpsEnabled: true
        )
        
        // 更新网络配置
        var config = NetworkManager.shared.config
        config.proxyConfig = proxyConfig
        NetworkManager.shared.config = config
        
        showAlert(title: "代理配置", message: "已配置代理: \(proxyConfig.host):\(proxyConfig.port)")
    }
    
    /// SSL证书配置示例
    private func demonstrateSSLCertificateConfig() {
        // 更新网络配置以允许无效证书（仅用于演示）
        var config = NetworkManager.shared.config
        config.allowInvalidCertificates = true
        NetworkManager.shared.config = config
        
        showAlert(title: "SSL证书配置", message: "已配置允许无效SSL证书")
    }
    
    /// 重定向处理示例
    private func demonstrateRedirectHandling() {
        // 更新网络配置以控制重定向
        var config = NetworkManager.shared.config
        config.allowRedirects = false
        config.maxRedirects = 5
        NetworkManager.shared.config = config
        
        showAlert(title: "重定向处理", message: "已配置重定向设置: 允许=\(config.allowRedirects), 最大次数=\(config.maxRedirects)")
    }
    
    /// 自定义加载指示器示例
    private func demonstrateCustomLoadingIndicator() {
        // 配置自定义加载指示器
        let config = LoadingIndicatorConfig(showDelay: 0.2, hideDelay: 0.1)
        LoadingIndicatorManager.shared.configure(with: config)
        
        // 创建一个自定义的加载指示器（简单的文本提示）
        class TextLoadingIndicator: LoadingIndicator {
            func show() {
                guard Thread.isMainThread else {
                    DispatchQueue.main.async {
                        self.show()
                    }
                    return
                }
                
                guard let window = UIApplication.shared.keyWindow else { return }
                
                // 创建提示标签
                let label = UILabel()
                label.text = "正在加载..."
                label.textColor = .white
                label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                label.textAlignment = .center
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                label.translatesAutoresizingMaskIntoConstraints = false
                label.tag = 888888
                
                // 避免重复添加
                if window.viewWithTag(888888) != nil {
                    return
                }
                
                window.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                    label.widthAnchor.constraint(equalToConstant: 120),
                    label.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
            
            func hide() {
                guard Thread.isMainThread else {
                    DispatchQueue.main.async {
                        self.hide()
                    }
                    return
                }
                
                guard let window = UIApplication.shared.keyWindow else { return }
                window.viewWithTag(888888)?.removeFromSuperview()
            }
            
            func willShow() {
                print("TextLoadingIndicator will show")
            }
            
            func didShow() {
                print("TextLoadingIndicator did show")
            }
            
            func willHide() {
                print("TextLoadingIndicator will hide")
            }
            
            func didHide() {
                print("TextLoadingIndicator did hide")
            }
        }
        
        // 设置自定义加载指示器
        LoadingIndicatorManager.shared.setIndicator(TextLoadingIndicator())
        
        // 发送一个需要显示加载指示器的请求
        let request = GetUserRequest(userId: 1)
        
        showAlert(title: "自定义加载指示器", message: "正在使用自定义加载指示器获取用户信息...")
        
        NetworkManager.shared.requestWithLoading(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成，使用了自定义加载指示器")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                    
                    // 恢复默认加载指示器
                    LoadingIndicatorManager.shared.setIndicator(DefaultLoadingIndicator())
                },
                receiveValue: { [weak self] (user: User) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n邮箱: \(user.email)\n使用了自定义加载指示器")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// Toast-Swift加载指示器示例
    private func demonstrateToastSwiftLoadingIndicator() {
        #if canImport(Toast_Swift)
        // 配置Toast-Swift加载指示器
        LoadingIndicatorConfigurationExample.configureToastLoadingIndicator()
        
        // 发送一个需要显示加载指示器的请求
        let request = GetUserRequest(userId: 1)
        
        showAlert(title: "Toast-Swift加载指示器", message: "正在使用Toast-Swift加载指示器获取用户信息...")
        
        NetworkManager.shared.requestWithLoading(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成，使用了Toast-Swift加载指示器")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                    
                    // 恢复默认加载指示器
                    LoadingIndicatorManager.shared.setIndicator(DefaultLoadingIndicator())
                },
                receiveValue: { [weak self] (user: User) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n邮箱: \(user.email)\n使用了Toast-Swift加载指示器")
                    }
                }
            )
            .store(in: &self.cancellables)
        #else
        showAlert(title: "依赖缺失", message: "Toast-Swift库未找到，请确保已安装该依赖")
        #endif
    }

    // MARK: - 原有示例方法
    
    /// 单个请求（带缓存）
    private func fetchUserWithCache() {
        let request = GetUserRequest(userId: 1)
        
        showAlert(title: "请求开始", message: "正在获取用户信息（带缓存）...")
        
        NetworkManager.shared.request<User>(request, useCache: true)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n邮箱: \(user.email)")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 单个请求（无缓存）
    private func fetchUserWithoutCache() {
        let request = GetUserRequest(userId: 1)
        
        showAlert(title: "请求开始", message: "正在获取用户信息（无缓存）...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n邮箱: \(user.email)")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 组合请求（带缓存）
    private func fetchUserAndPostsWithCache() {
        let userRequest = GetUserRequest(userId: 1)
        let postRequest = GetPostsRequest()
        
        showAlert(title: "请求开始", message: "正在获取用户和帖子信息（带缓存）...")
        
        let userPublisher: AnyPublisher<User, NetworkError> = NetworkManager.shared.request(userRequest, useCache: true)
        let postPublisher: AnyPublisher<Post, NetworkError> = NetworkManager.shared.request(postRequest, useCache: true)
        
        Publishers.Zip(userPublisher, postPublisher)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User, post: Post) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n帖子标题: \(post.title)")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 组合请求（无缓存）
    private func fetchUserAndPostsWithoutCache() {
        let userRequest = GetUserRequest(userId: 1)
        let postRequest = GetPostsRequest()
        
        showAlert(title: "请求开始", message: "正在获取用户和帖子信息（无缓存）...")
        
        let userPublisher: AnyPublisher<User, NetworkError> = NetworkManager.shared.request(userRequest)
        let postPublisher: AnyPublisher<Post, NetworkError> = NetworkManager.shared.request(postRequest)
        
        Publishers.Zip(userPublisher, postPublisher)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User, post: Post) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n帖子标题: \(post.title)")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 三个请求组合
    private func fetchUserPostAndUsers() {
        let userRequest = GetUserRequest(userId: 1)
        let postRequest = GetPostsRequest()
        let usersRequest = GetUsersRequest()
        
        showAlert(title: "请求开始", message: "正在获取用户、帖子和用户列表...")
        
        let userPublisher: AnyPublisher<User, NetworkError> = NetworkManager.shared.request(userRequest)
        let postPublisher: AnyPublisher<Post, NetworkError> = NetworkManager.shared.request(postRequest)
        let usersPublisher: AnyPublisher<[User], NetworkError> = NetworkManager.shared.request(usersRequest)
        
        Publishers.Zip3(userPublisher, postPublisher, usersPublisher)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (user: User, post: Post, users: [User]) in
                    DispatchQueue.main.async {
                        self?.showAlert(title: "成功", message: "用户名: \(user.name)\n帖子标题: \(post.title)\n用户总数: \(users.count)")
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 错误处理演示
    private func demonstrateErrorHandling() {
        // 创建一个会失败的请求（不存在的用户ID）
        struct GetNonExistentUserRequest: APIRequest {
            typealias Target = UserAPI
            
            func asTarget() -> UserAPI {
                return .getUser(id: 999999)
            }
            
            var needsLoadingIndicator: Bool { return true }
        }
        
        let request = GetNonExistentUserRequest()
        
        showAlert(title: "请求开始", message: "正在获取不存在的用户信息...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            // 直接处理NetworkError，因为request方法返回的就是NetworkError
                            switch error {
                            case .httpError(let code):
                                self?.showAlert(title: "HTTP错误", message: "状态码: \(code)")
                            case .networkUnreachable:
                                self?.showAlert(title: "网络错误", message: "网络不可达")
                            case .timeout:
                                self?.showAlert(title: "超时错误", message: "请求超时")
                            default:
                                self?.showAlert(title: "其他错误", message: "错误类型: \(error)")
                            }
                        }
                    }
                },
                receiveValue: { [weak self] (_: User) in
                    // 不需要处理成功的情况，因为请求会失败
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 弱网环境模拟
    private func simulateWeakNetwork() {
        // 创建一个需要弱网处理的请求
        struct WeakNetworkRequest: APIRequest {
            typealias Target = UserAPI
            
            func asTarget() -> UserAPI {
                return .getUser(id: 1)
            }
            
            var allowsWeakNetwork: Bool { return false } // 不允许在弱网环境下请求
            var needsLoadingIndicator: Bool { return true }
        }
        
        let request = WeakNetworkRequest()
        
        // 模拟弱网环境
        // 注意：我们不能直接设置networkStatus，因为它是只读的
        // 我们需要通过其他方式模拟弱网环境
        
        showAlert(title: "弱网环境", message: "正在模拟弱网环境下的请求...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            // 直接处理NetworkError，因为request方法返回的就是NetworkError
                            switch error {
                            case .weakNetworkNotAllowed:
                                self?.showAlert(title: "弱网限制", message: "当前为弱网环境，请求被拒绝")
                            default:
                                self?.showAlert(title: "错误", message: "错误: \(error.localizedDescription)")
                            }
                        }
                    }
                },
                receiveValue: { [weak self] (_: User) in
                    // 不需要处理成功的情况
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 弱网环境下允许请求的示例
    private func weakNetworkRequestAllowed() {
        // 创建一个允许在弱网环境下请求的请求
        struct WeakNetworkAllowedRequest: APIRequest {
            typealias Target = UserAPI
            
            func asTarget() -> UserAPI {
                return .getUser(id: 1)
            }
            
            var allowsWeakNetwork: Bool { return true } // 允许在弱网环境下请求
            var needsLoadingIndicator: Bool { return true }
        }
        
        let request = WeakNetworkAllowedRequest()
        
        // 模拟弱网环境
        // 注意：我们不能直接设置networkStatus，因为它是只读的
        
        showAlert(title: "弱网环境（允许请求）", message: "正在弱网环境下发送允许的请求...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "成功", message: "在弱网环境下成功发送了允许的请求")
                        case .failure(let error):
                            self?.showAlert(title: "失败", message: "错误: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] (_: User) in
                    // 不需要处理成功的情况
                }
            )
            .store(in: &self.cancellables)
    }
    
    /// 弱网环境下不允许请求的示例
    private func weakNetworkRequestNotAllowed() {
        // 创建一个不允许在弱网环境下请求的请求
        struct WeakNetworkNotAllowedRequest: APIRequest {
            typealias Target = UserAPI
            
            func asTarget() -> UserAPI {
                return .getUser(id: 1)
            }
            
            var allowsWeakNetwork: Bool { return false } // 不允许在弱网环境下请求
            var needsLoadingIndicator: Bool { return true }
        }
        
        let request = WeakNetworkNotAllowedRequest()
        
        // 模拟弱网环境
        // 注意：我们不能直接设置networkStatus，因为它是只读的
        
        showAlert(title: "弱网环境（不允许请求）", message: "正在弱网环境下发送不允许的请求...")
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    DispatchQueue.main.async {
                        switch completion {
                        case .finished:
                            self?.showAlert(title: "完成", message: "请求已完成")
                        case .failure(let error):
                            // 直接处理NetworkError，因为request方法返回的就是NetworkError
                            switch error {
                            case .weakNetworkNotAllowed:
                                self?.showAlert(title: "弱网限制", message: "请求被拒绝，因为当前为弱网环境且请求不允许在弱网下发送")
                            default:
                                self?.showAlert(title: "错误", message: "错误: \(error.localizedDescription)")
                            }
                        }
                    }
                },
                receiveValue: { [weak self] (_: User) in
                    // 不需要处理成功的情况
                }
            )
            .store(in: &self.cancellables)
    }
    
    // MARK: - 辅助方法
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension NetworkExamplesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath)
        let example = examples[indexPath.row]
        
        // 使用传统的UITableViewCell配置方式以确保兼容性
        cell.textLabel?.text = example.title
        cell.detailTextLabel?.text = example.description
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        examples[indexPath.row].action()
    }
}
