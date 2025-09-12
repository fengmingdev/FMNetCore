# 高级用法

## 拦截器

拦截器是 FMNetCore 的一个强大功能，允许您在请求发送前和响应接收后进行自定义处理。

### 创建自定义拦截器

要创建自定义拦截器，您需要实现 `NetworkInterceptor` 协议：

```swift
class CustomInterceptor: NetworkInterceptor {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        // 在请求发送前修改请求
        var modifiedRequest = request
        modifiedRequest.addValue("Bearer token", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        // 在响应接收后处理响应
        switch result {
        case .success(let response):
            // 处理成功的响应
            print("Received response with status code \(response.statusCode)")
        case .failure(let error):
            // 处理错误
            print("Request failed with error: \(error)")
        }
        return result
    }
}
```

### 注册拦截器

```swift
let interceptor = CustomInterceptor()
NetworkInterceptorManager.shared.addInterceptor(interceptor)
```

## 缓存管理

FMNetCore 内置了缓存管理功能，可以缓存网络请求的响应。

### 配置缓存

```swift
let cacheConfig = CacheConfig()
cacheConfig.maxDiskCacheSize = 100 * 1024 * 1024  // 100MB
cacheConfig.defaultMemoryExpiry = 600  // 10分钟
cacheConfig.defaultDiskExpiry = 3600  // 1小时

CacheManager.shared.enableCache(with: cacheConfig)
```

### 清除缓存

```swift
// 清除所有缓存
CacheManager.shared.clearCache()

// 清除内存缓存
CacheManager.shared.clearMemoryCache()

// 清除磁盘缓存
CacheManager.shared.clearDiskCache()
```

## 网络日志

FMNetCore 支持详细的网络日志记录，帮助您调试网络请求。

### 启用日志

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.enableLogging = true

let networkManager = NetworkManager(config: config)
```

### 自定义日志格式

您可以通过实现自定义的日志插件来修改日志格式：

```swift
class CustomLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        print("Sending request: \(request)")
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("Received response: \(response)")
        case .failure(let error):
            print("Request failed: \(error)")
        }
    }
}
```

## 网络可达性

FMNetCore 内置了网络可达性检测功能。

### 监听网络状态变化

```swift
ReachabilityManager.shared.$networkStatus
    .sink { status in
        switch status {
        case .unreachable:
            print("Network is unreachable")
        case .cellular(let quality):
            print("Cellular network with quality: \(quality)")
        case .wifi:
            print("WiFi network")
        }
    }
    .store(in: &cancellables)
```

## 加载指示器

FMNetCore 支持自动显示和隐藏加载指示器。

### 配置加载指示器

```swift
let loadingConfig = LoadingIndicatorConfig()
loadingConfig.showDelay = 0.5  // 0.5秒后显示加载指示器
loadingConfig.hideDelay = 0.3  // 0.3秒后隐藏加载指示器

LoadingIndicatorManager.shared.configure(with: loadingConfig)
```

### 自定义加载指示器

您可以实现 `LoadingIndicator` 协议来自定义加载指示器：

```swift
class CustomLoadingIndicator: LoadingIndicator {
    func show() {
        // 显示自定义加载指示器
    }
    
    func hide() {
        // 隐藏自定义加载指示器
    }
}

LoadingIndicatorManager.shared.setIndicator(CustomLoadingIndicator())
```

## 协程支持

FMNetCore 支持协程风格的异步编程。

### 使用协程发送请求

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

## 动态基础 URL

FMNetCore 支持动态更改基础 URL。

### 设置动态基础 URL

```swift
class DynamicBaseURLProvider: BaseURLProvider {
    func baseURL(for target: TargetType) -> URL {
        // 根据目标动态返回基础 URL
        if target is AuthAPI {
            return URL(string: "https://auth.api.example.com")!
        } else {
            return URL(string: "https://api.example.com")!
        }
    }
}

let dynamicBaseURL = DynamicBaseURL(provider: DynamicBaseURLProvider())
networkManager.config.baseURL = dynamicBaseURL
```

## 自定义重定向处理

FMNetCore 允许您自定义重定向处理逻辑。

### 创建自定义重定向处理器

```swift
class CustomRedirectHandler: RedirectHandler {
    func handle(
        _ task: HTTPURLResponse,
        response: HTTPURLResponse,
        completion: @escaping (URLRequest?) -> Void
    ) {
        // 自定义重定向处理逻辑
        if response.statusCode == 301 || response.statusCode == 302 {
            // 处理重定向
            completion(response.urlRequest)
        } else {
            // 不处理重定向
            completion(nil)
        }
    }
}
```

## 自定义服务器信任评估

FMNetCore 允许您自定义服务器信任评估逻辑，用于 SSL/TLS 证书验证。

### 创建自定义服务器信任评估器

```swift
class CustomServerTrustEvaluator: ServerTrustEvaluating {
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        // 自定义证书验证逻辑
        // 例如，允许自签名证书
        #if DEBUG
        // 在调试模式下允许所有证书
        #else
        // 在发布模式下进行正常验证
        try DefaultTrustEvaluator().evaluate(trust, forHost: host)
        #endif
    }
}
```