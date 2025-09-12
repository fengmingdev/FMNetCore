//
//  SimpleExample.swift
//  FMNetCore Examples
//
//  Created by Fengming on 2025/9/12.
//

import Foundation
import FMNetCore

// 定义一个简单的 API
enum SimpleAPI {
    case getUsers
    case getUser(id: Int)
}

extension SimpleAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
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
        return ["Content-Type": "application/json"]
    }
}

// 使用 FMNetCore 进行网络请求
func example() {
    let networkManager = NetworkManager.shared
    
    // 获取所有用户
    networkManager.request(SimpleAPI.getUsers) { result in
        switch result {
        case .success(let response):
            print("Successfully fetched users")
            print("Status code: \(response.statusCode)")
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
        case .failure(let error):
            print("Failed to fetch users: \(error)")
        }
    }
    
    // 获取特定用户
    networkManager.request(SimpleAPI.getUser(id: 1)) { result in
        switch result {
        case .success(let response):
            print("Successfully fetched user")
            print("Status code: \(response.statusCode)")
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
        case .failure(let error):
            print("Failed to fetch user: \(error)")
        }
    }
}