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