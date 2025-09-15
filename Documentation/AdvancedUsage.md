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

FMNetCore 支持自动显示和隐藏加载指示器，并且支持外部自定义。

### 配置加载指示器

```swift
let loadingConfig = LoadingIndicatorConfig()
loadingConfig.showDelay = 0.5  // 0.5秒后显示加载指示器
loadingConfig.hideDelay = 0.3  // 0.3秒后隐藏加载指示器
loadingConfig.preventDuplicateShow = true  // 防止重复显示
loadingConfig.minimumDisplayTime = 0.1  // 最小显示时间，防止闪烁

LoadingIndicatorManager.shared.configure(with: loadingConfig)
```

### 自定义加载指示器

您可以实现 `LoadingIndicator` 协议来自定义加载指示器：

```swift
class CustomLoadingIndicator: LoadingIndicator {
    func show() {
        // 显示自定义加载指示器
        // 例如，使用MBProgressHUD、SVProgressHUD等第三方库
        DispatchQueue.main.async {
            // 在主线程中显示您的自定义加载视图
        }
    }
    
    func hide() {
        // 隐藏自定义加载指示器
        DispatchQueue.main.async {
            // 在主线程中隐藏您的自定义加载视图
        }
    }
    
    // 可选的生命周期回调方法
    func willShow() async {
        // 加载指示器将要显示时调用
        print("Loading indicator will show")
    }
    
    func didShow() async {
        // 加载指示器已经显示时调用
        print("Loading indicator did show")
    }
    
    func willHide() async {
        // 加载指示器将要隐藏时调用
        print("Loading indicator will hide")
    }
    
    func didHide() async {
        // 加载指示器已经隐藏时调用
        print("Loading indicator did hide")
    }
}

LoadingIndicatorManager.shared.setIndicator(CustomLoadingIndicator())
```

### 使用Toast-Swift库的加载指示器

如果您想使用Toast-Swift库来显示加载指示器，可以这样实现：

```swift
import Toast_Swift

class ToastLoadingIndicator: LoadingIndicator {
    func show() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            
            // 使用Toast-Swift显示加载提示
            window.makeToastActivity(.center)
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else { return }
            
            // 隐藏Toast-Swift加载提示
            window.hideToastActivity()
        }
    }
    
    // 实现可选的生命周期回调方法
    func willShow() async {
        print("ToastLoadingIndicator will show")
    }
    
    func didShow() async {
        print("ToastLoadingIndicator did show")
    }
    
    func willHide() async {
        print("ToastLoadingIndicator will hide")
    }
    
    func didHide() async {
        print("ToastLoadingIndicator did hide")
    }
}

// 设置Toast-Swift加载指示器
LoadingIndicatorManager.shared.setIndicator(ToastLoadingIndicator())
```

### 加载指示器管理功能

LoadingIndicatorManager 提供了丰富的管理功能：

```swift
// 检查加载指示器是否可见
let isVisible = LoadingIndicatorManager.shared.isVisible()

// 获取当前加载任务数量
let loadingCount = LoadingIndicatorManager.shared.getLoadingCount()

// 获取当前配置
let config = LoadingIndicatorManager.shared.getCurrentConfig()

// 获取所有加载任务信息
let tasks = LoadingIndicatorManager.shared.getAllTasks()

// 取消所有加载指示器
LoadingIndicatorManager.shared.cancelAllLoading()
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

## SwiftProtobuf 支持

FMNetCore 提供了对 SwiftProtobuf 的完整支持，允许您使用 Protocol Buffers 进行高效的数据序列化。

### 配置依赖

要使用 SwiftProtobuf，您需要在项目中添加依赖：

#### 使用 Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/fengmingdev/FMNetCore.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0")
]
```

#### 使用 CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'FMNetCore', '~> 1.0'
pod 'SwiftProtobuf', '~> 1.26'
```

### 使用 ProtobufAPIRequest

创建符合 `ProtobufAPIRequest` 协议的请求：

```swift
import FMNetCore
import SwiftProtobuf

// 假设您有一个由.proto文件生成的User消息
// message User {
//   int32 id = 1;
//   string name = 2;
//   string email = 3;
// }

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
    
    // 可选：自定义重试次数
    var retryCount: Int? { return 2 }
    
    // 可选：是否需要显示加载指示器
    var needsLoadingIndicator: Bool { true }
}
```

### 发送 Protobuf 请求

```swift
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

### Protobuf 缓存支持

FMNetCore 的 Protobuf 支持也包含缓存功能：

```swift
// 使用缓存发送请求
networkManager.request(request, useCache: true)
    .sink(
        receiveCompletion: { completion in
            // 处理完成
        },
        receiveValue: { user in
            // 处理用户数据
        }
    )
    .store(in: &cancellables)
```

## RxSwift 支持

FMNetCore 提供了对 RxSwift 的完整支持，允许您使用响应式编程模式。

### 配置依赖

要使用 RxSwift，您需要在项目中添加依赖：

#### 使用 Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/fengmingdev/FMNetCore.git", from: "1.0.0"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
]
```

#### 使用 CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'FMNetCore', '~> 1.0'
pod 'RxSwift', '~> 6.5'
pod 'RxCocoa', '~> 6.5'
```

### 使用 RxSwift 扩展

FMNetCore 提供了多种 RxSwift 扩展方法：

#### 基本请求

```swift
import FMNetCore
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()
let request = GetUsersRequest()

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
```

#### Protobuf 请求

```swift
// 发送Protobuf请求
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
```

#### 组合请求

```swift
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

#### 与 UI 绑定

```swift
let searchTextField = UITextField()
let resultLabel = UILabel()
let activityIndicator = UIActivityIndicatorView()

// 设置UI
searchTextField.placeholder = "搜索用户..."
resultLabel.text = "请输入搜索关键词"

// 使用RxCocoa绑定
searchTextField.rx.text
    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    .compactMap { $0 }
    .filter { !$0.isEmpty }
    .distinctUntilChanged()
    .do(onNext: { _ in
        activityIndicator.startAnimating()
    })
    .flatMapLatest { query -> Observable<[User]> in
        let request = SearchUsersRequest(query: query)
        return NetworkManager.shared.rxRequest([User].self, request)
            .catchAndReturn([])
    }
    .do(onNext: { _ in
        activityIndicator.stopAnimating()
    })
    .map { users in "找到 \(users.count) 个用户" }
    .bind(to: resultLabel.rx.text)
    .disposed(by: disposeBag)

// 错误处理示例
searchTextField.rx.text
    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    .compactMap { $0 }
    .filter { !$0.isEmpty }
    .distinctUntilChanged()
    .flatMapLatest { query -> Observable<[User]> in
        let request = SearchUsersRequest(query: query)
        return NetworkManager.shared.rxRequest([User].self, request)
    }
    .subscribe(
        onNext: { users in
            resultLabel.text = "找到 \(users.count) 个用户"
        },
        onError: { error in
            resultLabel.text = "搜索失败: \(error.localizedDescription)"
        }
    )
    .disposed(by: disposeBag)
```

#### 重试和错误处理

```swift
let request = GetUsersRequest()

// 重试机制
NetworkManager.shared.rxRequest([User].self, request)
    .retry(3) // 重试3次
    .subscribe(
        onNext: { users in
            print("成功获取 \(users.count) 个用户")
        },
        onError: { error in
            print("获取用户失败: \(error)")
        }
    )
    .disposed(by: disposeBag)

// 错误恢复
NetworkManager.shared.rxRequest([User].self, request)
    .catchAndReturn([]) // 错误时返回空数组
    .subscribe(
        onNext: { users in
            print("获取用户结果: \(users.count) 个用户")
        }
    )
    .disposed(by: disposeBag)
```

#### 轮询请求

```swift
// 创建一个定时轮询的Observable
extension NetworkManager {
    /// 创建一个定时轮询的Observable
    /// - Parameters:
    ///   - request: 请求对象
    ///   - interval: 轮询间隔
    /// - Returns: Observable
    public func rxPollingRequest<T: Decodable, R: APIRequest>(
        _ request: R,
        interval: RxTimeInterval
    ) -> Observable<T> {
        return Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .flatMapLatest { _ in
                return self.rxRequest(T.self, request)
            }
    }
}

// 使用轮询
NetworkManager.shared.rxPollingRequest([User].self, GetUsersRequest(), interval: .seconds(10))
    .subscribe(
        onNext: { users in
            print("轮询获取到 \(users.count) 个用户")
        },
        onError: { error in
            print("轮询失败: \(error)")
        }
    )
    .disposed(by: disposeBag)
```