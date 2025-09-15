//
//  ViewController.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/12.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import FMNetCore
import Combine

#if canImport(UIKit)
class ViewController: UIViewController {
    
    private var tableView: UITableView!
    private var examples: [Example] = []
    private var logTextView: UITextView!
    private var cancellables = Set<AnyCancellable>()
    
    struct Example {
        let title: String
        let action: () -> Void
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExamples()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "FMNetCore 示例"
        
        // 创建表格视图
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExampleCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 创建日志文本视图
        logTextView = UITextView()
        logTextView.isEditable = false
        logTextView.backgroundColor = .secondarySystemBackground
        logTextView.font = UIFont.systemFont(ofSize: 12)
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logTextView)
        
        // 添加导航栏按钮
        let clearLogsButton = UIBarButtonItem(
            title: "清除日志",
            style: .plain,
            target: self,
            action: #selector(clearLogsTapped)
        )
        
        navigationItem.rightBarButtonItem = clearLogsButton
        
        // 设置约束
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            
            logTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupExamples() {
        examples = [
            Example(
                title: "获取用户列表",
                action: fetchUsers
            ),
            Example(
                title: "获取单个用户",
                action: fetchUser
            ),
            Example(
                title: "组合请求",
                action: combinedRequest
            )
        ]
        
        // 添加RxSwift示例（如果可用）
        #if canImport(RxSwift)
        examples.append(Example(
            title: "RxSwift示例",
            action: showRxSwiftExample
        ))
        #endif
        
        // 添加Protobuf示例（如果可用）
        #if canImport(SwiftProtobuf)
        examples.append(Example(
            title: "Protobuf示例",
            action: showProtobufExample
        ))
        #endif
        
        tableView.reloadData()
    }
    
    @objc private func clearLogsTapped() {
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
    
    // 示例方法
    private func fetchUsers() {
        log("开始获取用户列表...")
        
        // 使用示例项目中的GetUsersRequest
        let request = GetUsersRequest()
        
        NetworkManager.shared.request<[User]>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    switch completion {
                    case .finished:
                        self?.log("获取用户列表完成")
                    case .failure(let error):
                        self?.log("获取用户列表失败: \(error)")
                    }
                },
                receiveValue: { [weak self] (users: [User]) in
                    self?.log("成功获取 \(users.count) 个用户")
                }
            )
            .store(in: &self.cancellables)
    }
    
    private func fetchUser() {
        log("开始获取ID为1的用户...")
        
        // 使用示例项目中的GetUserRequest
        let request = GetUserRequest(userId: 1)
        
        NetworkManager.shared.request<User>(request)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    switch completion {
                    case .finished:
                        self?.log("获取用户完成")
                    case .failure(let error):
                        self?.log("获取用户失败: \(error)")
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    self?.log("成功获取用户: \(user.name)")
                }
            )
            .store(in: &self.cancellables)
    }
    
    private func combinedRequest() {
        log("开始组合请求...")
        
        // 使用示例项目中的请求
        let usersRequest = GetUsersRequest()
        let postsRequest = GetPostsRequest()
        
        // 并行发送两个请求
        let usersPublisher: AnyPublisher<[User], NetworkError> = NetworkManager.shared.request(usersRequest)
        let postsPublisher: AnyPublisher<[Post], NetworkError> = NetworkManager.shared.request(postsRequest)
        
        Publishers.Zip(usersPublisher, postsPublisher)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<NetworkError>) in
                    switch completion {
                    case .finished:
                        self?.log("组合请求完成")
                    case .failure(let error):
                        self?.log("组合请求失败: \(error)")
                    }
                },
                receiveValue: { [weak self] (users: [User], posts: [Post]) in
                    self?.log("成功获取 \(users.count) 个用户和 \(posts.count) 个帖子")
                }
            )
            .store(in: &self.cancellables)
    }
    
    #if canImport(RxSwift)
    private func showRxSwiftExample() {
        log("显示RxSwift示例...")
        let alert = UIAlertController(title: "RxSwift支持", message: "FMNetCore已启用RxSwift支持。您可以在项目中使用rxRequest、rxRequestWithLoading等方法。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    #endif
    
    #if canImport(SwiftProtobuf)
    private func showProtobufExample() {
        log("显示Protobuf示例...")
        let alert = UIAlertController(title: "Protobuf支持", message: "FMNetCore已启用Protobuf支持。您可以实现ProtobufAPIRequest协议来使用Protobuf序列化。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    #endif
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath)
        cell.textLabel?.text = examples[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        examples[indexPath.row].action()
    }
}
#endif
