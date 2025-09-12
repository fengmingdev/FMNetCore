# 迁移指南

本指南将帮助您从其他网络库迁移到 FMNetCore。

## 从 Alamofire 迁移

### 基本请求

**Alamofire:**
```swift
import Alamofire

AF.request("https://api.example.com/users").responseJSON { response in
    switch response.result {
    case .success(let value):
        print("JSON: \(value)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

**FMNetCore:**
```swift
import FMNetCore

enum UserAPI: TargetType {
    case getUsers
    
    var baseURL: URL { return URL(string: "https://api.example.com")! }
    var path: String { return "/users" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestPlain }
    var headers: [String: String]? { return nil }
}

let networkManager = NetworkManager.shared
networkManager.request(UserAPI.getUsers) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### 带参数的请求

**Alamofire:**
```swift
AF.request("https://api.example.com/users", method: .post, parameters: ["name": "John", "email": "john@example.com"])
```

**FMNetCore:**
```swift
enum UserAPI: TargetType {
    case createUser(name: String, email: String)
    
    var baseURL: URL { return URL(string: "https://api.example.com")! }
    var path: String { return "/users" }
    var method: Moya.Method { return .post }
    var task: Task {
        return .requestParameters(parameters: ["name": name, "email": email], encoding: JSONEncoding.default)
    }
    var headers: [String: String]? { return ["Content-Type": "application/json"] }
}

networkManager.request(UserAPI.createUser(name: "John", email: "john@example.com"))
```

## 从 Moya 迁移

如果您已经在使用 Moya，迁移到 FMNetCore 相对简单，因为 FMNetCore 基于 Moya 构建。

### 配置网络管理器

**Moya:**
```swift
let provider = MoyaProvider<MyAPI>()
```

**FMNetCore:**
```swift
let networkManager = NetworkManager.shared
// 或者自定义配置
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
let networkManager = NetworkManager(config: config)
```

### 发送请求

**Moya:**
```swift
provider.request(.getUsers) { result in
    // 处理结果
}
```

**FMNetCore:**
```swift
networkManager.request(MyAPI.getUsers) { result in
    // 处理结果
}
```

## 从 URLSession 迁移

### 基本 GET 请求

**URLSession:**
```swift
let url = URL(string: "https://api.example.com/users")!
let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    guard let data = data else {
        print("No data received")
        return
    }
    
    // 处理数据
}
task.resume()
```

**FMNetCore:**
```swift
enum UserAPI: TargetType {
    case getUsers
    
    var baseURL: URL { return URL(string: "https://api.example.com")! }
    var path: String { return "/users" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestPlain }
    var headers: [String: String]? { return nil }
}

let networkManager = NetworkManager.shared
networkManager.request(UserAPI.getUsers) { result in
    switch result {
    case .success(let response):
        // 处理响应
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## 从 AFNetworking 迁移 (Objective-C)

如果您正在从 Objective-C 的 AFNetworking 迁移到 Swift 的 FMNetCore，这是一个更大的变化。

### 基本请求

**AFNetworking:**
```objc
AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
[manager GET:@"https://api.example.com/users" parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
} failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

**FMNetCore:**
```swift
enum UserAPI: TargetType {
    case getUsers
    
    var baseURL: URL { return URL(string: "https://api.example.com")! }
    var path: String { return "/users" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestPlain }
    var headers: [String: String]? { return nil }
}

let networkManager = NetworkManager.shared
networkManager.request(UserAPI.getUsers) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## 迁移检查清单

在迁移过程中，请确保完成以下步骤：

1. [ ] 识别所有网络请求点
2. [ ] 创建对应的 TargetType 枚举
3. [ ] 配置 NetworkManager
4. [ ] 更新错误处理逻辑
5. [ ] 测试所有网络请求
6. [ ] 更新文档和注释
7. [ ] 移除旧的网络库依赖
8. [ ] 更新 CI/CD 配置
9. [ ] 更新团队成员培训材料

## 注意事项

1. **错误处理**: FMNetCore 使用 Swift 的 Result 类型进行错误处理，与许多其他库不同。
2. **异步处理**: FMNetCore 默认使用闭包回调，但也支持 Combine 和协程。
3. **配置**: FMNetCore 提供了丰富的配置选项，可以根据需要进行定制。
4. **测试**: FMNetCore 内置了测试支持，可以更容易地编写网络请求测试。