//
//  ExampleAPIRequests.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Moya
import FMNetCore

// 示例数据模型
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// 用户相关请求的TargetType实现
enum UserAPI {
    case getUser(id: Int)
    case getUsers
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getUser(let id):
            return "/users/\(id)"
        case .getUsers:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

// 获取单个用户的请求实现
struct GetUserRequest: APIRequest, Encodable {
    typealias Target = UserAPI
    
    let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func asTarget() -> UserAPI {
        return .getUser(id: userId)
    }
    
    // 可以自定义超时时间
    var timeoutInterval: TimeInterval? {
        return 15.0
    }
    
    // 获取单个用户时显示加载指示器
    var needsLoadingIndicator: Bool {
        return true
    }
}

// 获取用户列表的请求实现
struct GetUsersRequest: APIRequest {
    typealias Target = UserAPI
    
    func asTarget() -> UserAPI {
        return .getUsers
    }
    
    // 获取用户列表时不显示加载指示器
    var needsLoadingIndicator: Bool {
        return false
    }
}

// 帖子相关请求的TargetType实现
enum PostAPI {
    case getPosts
    case getPost(id: Int)
}

extension PostAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        case .getPost(let id):
            return "/posts/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

// 获取帖子列表的请求实现
struct GetPostsRequest: APIRequest {
    typealias Target = PostAPI
    
    func asTarget() -> PostAPI {
        return .getPosts
    }
    
    // 获取帖子列表时显示加载指示器
    var needsLoadingIndicator: Bool {
        return true
    }
}

// 支持动态Base URL的示例请求
enum DynamicUserAPI: DynamicBaseURLTargetType {
    case getUser(id: Int)
    case getUsers
    
    var dynamicBaseURL: URL? {
        // 从动态Base URL管理器中获取URL
        return DynamicBaseURLManager.shared.getDynamicBaseURL(for: "userAPI")
    }
    
    var defaultBaseURL: URL {
        // 默认Base URL
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getUser(let id):
            return "/users/\(id)"
        case .getUsers:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

// 动态Base URL请求实现
struct GetDynamicUserRequest: APIRequest {
    typealias Target = DynamicUserAPI
    
    let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func asTarget() -> DynamicUserAPI {
        return .getUser(id: userId)
    }
    
    var needsLoadingIndicator: Bool {
        return true
    }
}