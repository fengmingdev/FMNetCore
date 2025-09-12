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

#if canImport(UIKit)
class ViewController: UIViewController {
    
    private var tableView: UITableView!
    private var examples: [Example] = []
    private var logTextView: UITextView!
    
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
        
        enum UserAPI: TargetType {
            case getUsers
            
            var baseURL: URL {
                return URL(string: "https://jsonplaceholder.typicode.com")!
            }
            
            var path: String {
                return "/users"
            }
            
            var method: Moya.Method {
                return .get
            }
            
            var task: Task {
                return .requestPlain
            }
            
            var headers: [String: String]? {
                return nil
            }
        }
        
        NetworkManager.shared.request(UserAPI.getUsers) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.log("成功获取用户列表，状态码: \(response.statusCode)")
                case .failure(let error):
                    self?.log("获取用户列表失败: \(error)")
                }
            }
        }
    }
    
    private func fetchUser() {
        log("开始获取ID为1的用户...")
        
        enum UserAPI: TargetType {
            case getUser(id: Int)
            
            var baseURL: URL {
                return URL(string: "https://jsonplaceholder.typicode.com")!
            }
            
            var path: String {
                switch self {
                case .getUser(let id):
                    return "/users/\(id)"
                }
            }
            
            var method: Moya.Method {
                return .get
            }
            
            var task: Task {
                return .requestPlain
            }
            
            var headers: [String: String]? {
                return nil
            }
        }
        
        NetworkManager.shared.request(UserAPI.getUser(id: 1)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.log("成功获取用户，状态码: \(response.statusCode)")
                case .failure(let error):
                    self?.log("获取用户失败: \(error)")
                }
            }
        }
    }
    
    private func combinedRequest() {
        log("开始组合请求...")
        
        enum UserAPI: TargetType {
            case getUsers
            
            var baseURL: URL {
                return URL(string: "https://jsonplaceholder.typicode.com")!
            }
            
            var path: String {
                return "/users"
            }
            
            var method: Moya.Method {
                return .get
            }
            
            var task: Task {
                return .requestPlain
            }
            
            var headers: [String: String]? {
                return nil
            }
        }
        
        enum PostAPI: TargetType {
            case getPosts
            
            var baseURL: URL {
                return URL(string: "https://jsonplaceholder.typicode.com")!
            }
            
            var path: String {
                return "/posts"
            }
            
            var method: Moya.Method {
                return .get
            }
            
            var task: Task {
                return .requestPlain
            }
            
            var headers: [String: String]? {
                return nil
            }
        }
        
        let request1 = UserAPI.getUsers
        let request2 = PostAPI.getPosts
        
        // 这里我们模拟组合请求
        NetworkManager.shared.request(request1) { [weak self] result1 in
            DispatchQueue.main.async {
                switch result1 {
                case .success(let response):
                    self?.log("成功获取用户列表，状态码: \(response.statusCode)")
                case .failure(let error):
                    self?.log("获取用户列表失败: \(error)")
                }
            }
        }
        
        NetworkManager.shared.request(request2) { [weak self] result2 in
            DispatchQueue.main.async {
                switch result2 {
                case .success(let response):
                    self?.log("成功获取帖子列表，状态码: \(response.statusCode)")
                case .failure(let error):
                    self?.log("获取帖子列表失败: \(error)")
                }
            }
        }
    }
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