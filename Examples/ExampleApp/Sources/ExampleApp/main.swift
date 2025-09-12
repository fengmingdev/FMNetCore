//
//  main.swift
//  ExampleApp
//
//  Created by Fengming on 2025/9/12.
//

import Foundation
import FMNetCore

// 定义示例 API
enum ExampleAPI {
    case getUsers
    case getUser(id: Int)
    case createUser(name: String, email: String)
}

extension ExampleAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUsers, .getUser:
            return .get
        case .createUser:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getUsers, .getUser:
            return .requestPlain
        case .createUser(let name, let email):
            return .requestParameters(
                parameters: ["name": name, "email": email],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createUser:
            return ["Content-Type": "application/json"]
        default:
            return nil
        }
    }
}

// 自定义拦截器
class LoggingInterceptor: NetworkInterceptor {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        print("🚀 Sending request to \(request.url?.absoluteString ?? "")")
        return request
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        switch result {
        case .success(let response):
            print("✅ Received response with status code \(response.statusCode)")
        case .failure(let error):
            print("❌ Request failed with error: \(error)")
        }
        return result
    }
}

// 主函数
func main() {
    print("FMNetCore Example App")
    print("====================")
    
    // 配置网络管理器
    var config = NetworkConfig(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    config.enableLogging = true
    config.maxRetryCount = 3
    config.retryInterval = 1.0
    
    let networkManager = NetworkManager(config: config)
    
    // 添加拦截器
    NetworkInterceptorManager.shared.addInterceptor(LoggingInterceptor())
    
    // 示例1: 获取所有用户
    print("\n1. 获取所有用户:")
    let getUsersTaskId = networkManager.requestWithLoading(ExampleAPI.getUsers) { result in
        switch result {
        case .success(let response):
            print("   成功获取用户列表，状态码: \(response.statusCode)")
            if let jsonString = String(data: response.data, encoding: .utf8) {
                let users = jsonString.prefix(200) + "..."
                print("   响应数据 (前200字符): \(users)")
            }
        case .failure(let error):
            print("   获取用户列表失败: \(error)")
        }
    }
    
    // 等待一段时间以确保请求完成
    Thread.sleep(forTimeInterval: 2.0)
    
    // 示例2: 获取特定用户
    print("\n2. 获取ID为1的用户:")
    let getUserTaskId = networkManager.requestWithLoading(ExampleAPI.getUser(id: 1)) { result in
        switch result {
        case .success(let response):
            print("   成功获取用户，状态码: \(response.statusCode)")
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("   用户信息: \(jsonString)")
            }
        case .failure(let error):
            print("   获取用户失败: \(error)")
        }
    }
    
    // 等待一段时间以确保请求完成
    Thread.sleep(forTimeInterval: 2.0)
    
    // 示例3: 创建新用户
    print("\n3. 创建新用户:")
    let createUserTaskId = networkManager.requestWithLoading(ExampleAPI.createUser(name: "John Doe", email: "john@example.com")) { result in
        switch result {
        case .success(let response):
            print("   成功创建用户，状态码: \(response.statusCode)")
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("   创建的用户: \(jsonString)")
            }
        case .failure(let error):
            print("   创建用户失败: \(error)")
        }
    }
    
    // 等待一段时间以确保请求完成
    Thread.sleep(forTimeInterval: 2.0)
    
    // 示例4: 使用 Combine
    #if canImport(Combine)
    print("\n4. 使用 Combine:")
    var cancellables = Set<AnyCancellable>()
    
    networkManager.requestPublisher(ExampleAPI.getUsers)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("   Combine 请求失败: \(error)")
            }
        }, receiveValue: { response in
            print("   Combine 成功获取用户列表，状态码: \(response.statusCode)")
        })
        .store(in: &cancellables)
    
    // 等待一段时间以确保请求完成
    Thread.sleep(forTimeInterval: 2.0)
    #endif
    
    // 示例5: 组合请求
    print("\n5. 组合请求:")
    let combinedTaskId = networkManager.combinedRequest(
        ExampleAPI.getUsers,
        ExampleAPI.getUser(id: 1)
    ) { result in
        switch result {
        case .success(let (usersResponse, userResponse)):
            print("   成功获取组合请求结果")
            print("   用户列表状态码: \(usersResponse.statusCode)")
            print("   特定用户状态码: \(userResponse.statusCode)")
        case .failure(let error):
            print("   组合请求失败: \(error)")
        }
    }
    
    // 等待一段时间以确保请求完成
    Thread.sleep(forTimeInterval: 3.0)
    
    print("\n示例应用执行完成!")
}

// 运行主函数
main()

// 保持程序运行
RunLoop.main.run()