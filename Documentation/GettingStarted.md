# 入门指南

## 安装

### Swift Package Manager

在 Xcode 中，选择 File > Swift Packages > Add Package Dependency，然后输入以下 URL：

```
https://github.com/your-username/FMNetCore.git
```

或者在 Package.swift 文件中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/your-username/FMNetCore.git", from: "1.0.0")
]
```

### CocoaPods

FMNetCore 也支持通过 CocoaPods 安装。要使用 CocoaPods 集成 FMNetCore 到您的项目中，请在您的 Podfile 中添加以下内容：

```ruby
pod 'FMNetCore', '~> 1.0'
```

然后运行：

```bash
pod install
```

## 基本用法

### 创建网络管理器

FMNetCore 使用单例模式，可以通过 `NetworkManager.shared` 访问全局实例：

```swift
import FMNetCore

let networkManager = NetworkManager.shared
```

### 发送网络请求

```swift
networkManager.request(ExampleAPIRequests.getUsers) { result in
    switch result {
    case .success(let response):
        // 处理成功响应
        print(response)
    case .failure(let error):
        // 处理错误
        print(error)
    }
}
```

### 配置网络管理器

可以通过 `NetworkConfig` 配置网络管理器：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.timeoutInterval = 20.0
config.enableLogging = true
config.maxRetryCount = 3

let networkManager = NetworkManager(config: config)
```

## 高级用法

### 使用拦截器

拦截器允许您在请求发送前和响应接收后进行自定义处理：

```swift
class CustomInterceptor: NetworkInterceptor {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.addValue("Bearer token", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        // 处理响应
        return result
    }
}

let interceptor = CustomInterceptor()
NetworkInterceptorManager.shared.addInterceptor(interceptor)
```

### 使用缓存

FMNetCore 内置了缓存管理功能：

```swift
// 启用缓存
let cacheConfig = CacheConfig()
CacheManager.shared.enableCache(with: cacheConfig)

// 清除缓存
CacheManager.shared.clearCache()
```

### 使用 Combine

FMNetCore 支持 Combine 框架：

```swift
networkManager.requestPublisher(ExampleAPIRequests.getUsers)
    .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
            print("Error: \(error)")
        }
    }, receiveValue: { response in
        print("Response: \(response)")
    })
    .store(in: &cancellables)
```

### 使用协程

FMNetCore 支持协程风格的异步编程：

```swift
let taskId = networkManager.requestWithLoading(ExampleAPIRequests.getUsers) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// 可以取消任务
CoroutineManager.shared.cancelTask(taskId)
```

## SwiftProtobuf 支持

FMNetCore 提供了对 SwiftProtobuf 的可选支持。要使用此功能，您需要在项目中添加 SwiftProtobuf 依赖。

### 安装依赖

#### 使用 Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0")
]
```

#### 使用 CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'SwiftProtobuf', '~> 1.26'
```

### 定义 Protobuf 消息

首先，您需要定义 `.proto` 文件并生成 Swift 代码。例如，创建一个 `user.proto` 文件：

```protobuf
syntax = "proto3";

message User {
  int32 id = 1;
  string name = 2;
  string email = 3;
}
```

然后使用 `protoc` 和 `protoc-gen-swift` 生成 Swift 代码：

```bash
protoc --swift_out=. user.proto
```

### 使用 Protobuf 请求

```swift
import FMNetCore
import SwiftProtobuf

// 实现 ProtobufAPIRequest 协议
struct GetUserProtobufRequest: ProtobufAPIRequest {
    typealias Target = UserAPI
    typealias RequestMessage = User  // 由.proto生成的消息
    typealias ResponseMessage = User // 由.proto生成的消息
    
    let userId: Int
    
    func asTarget() -> UserAPI {
        return .getUser(id: userId)
    }
    
    func buildRequestMessage() -> User? {
        // 构建请求消息（如果需要发送数据到服务器）
        let request = User()
        request.id = Int32(userId)
        return request
    }
    
    func parseResponseMessage(from data: Data) throws -> User {
        // 解析响应消息
        return try User(serializedData: data)
    }
    
    // 可选：自定义配置
    var retryCount: Int? { return 2 }
    var needsLoadingIndicator: Bool { true }
}

// 发送请求
let request = GetUserProtobufRequest(userId: 1)

// 使用 Combine
networkManager.request(request)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("请求完成")
            case .failure(let error):
                print("请求失败: \(error)")
            }
        },
        receiveValue: { user in
            print("成功获取用户: \(user.name)")
        }
    )
    .store(in: &cancellables)

// 使用回调方式
networkManager.requestWithLoading(request) { result in
    switch result {
    case .success(let user):
        print("成功获取用户: \(user.name)")
    case .failure(let error):
        print("获取用户失败: \(error)")
    }
}
```

## RxSwift 支持

FMNetCore 提供了对 RxSwift 的可选支持。要使用此功能，您需要在项目中添加 RxSwift 依赖。

### 安装依赖

#### 使用 Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
]
```

#### 使用 CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'RxSwift', '~> 6.5'
pod 'RxCocoa', '~> 6.5'
```

### 使用 RxSwift 扩展

```swift
import FMNetCore
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()
let request = GetUsersRequest()

// 基本请求
NetworkManager.shared.rxRequest([User].self, request)
    .subscribe(
        onNext: { users in
            print("成功获取 \(users.count) 个用户")
        },
        onError: { error in
            print("获取用户失败: \(error)")
        },
        onCompleted: {
            print("请求完成")
        }
    )
    .disposed(by: disposeBag)

// Protobuf请求
let protobufRequest = GetUserProtobufRequest(userId: 1)
NetworkManager.shared.rxRequest(protobufRequest)
    .subscribe(
        onNext: { user in
            print("成功获取用户: \(user.name)")
        },
        onError: { error in
            print("获取用户失败: \(error)")
        }
    )
    .disposed(by: disposeBag)

// 组合请求
let usersRequest = GetUsersRequest()
let postsRequest = GetPostsRequest()

NetworkManager.shared.rxCombinedRequest([User].self, [Post].self, usersRequest, postsRequest)
    .subscribe(
        onNext: { (users, posts) in
            print("成功获取 \(users.count) 个用户和 \(posts.count) 个帖子")
        },
        onError: { error in
            print("组合请求失败: \(error)")
        }
    )
    .disposed(by: disposeBag)
```

## 最佳实践

### 错误处理

始终正确处理网络错误：

```swift
networkManager.request(request) { result in
    switch result {
    case .success(let response):
        // 处理成功响应
        handleSuccess(response)
    case .failure(let error):
        // 根据错误类型进行不同处理
        switch error {
        case .networkUnreachable:
            showNetworkErrorAlert()
        case .timeout:
            showTimeoutAlert()
        case .httpError(let code):
            handleHTTPError(code)
        default:
            showGenericErrorAlert()
        }
    }
}
```

### 内存管理

确保正确管理订阅和任务：

```swift
class MyViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        networkManager.request(request)
            .sink(
                receiveCompletion: { completion in
                    // 处理完成
                },
                receiveValue: { value in
                    // 处理值
                }
            )
            .store(in: &cancellables) // 存储到cancellables中，确保正确释放
    }
}
```

### 配置管理

使用配置来管理不同的环境：

```swift
enum Environment {
    case development
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev.api.example.com")!
        case .staging:
            return URL(string: "https://staging.api.example.com")!
        case .production:
            return URL(string: "https://api.example.com")!
        }
    }
}

// 根据环境创建网络管理器
let environment: Environment = .production
var config = NetworkConfig(baseURL: environment.baseURL)
let networkManager = NetworkManager(config: config)
```