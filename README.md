# FMNetCore

FMNetCore 是一个功能强大的 iOS 网络库，基于 Alamofire 和 Moya 构建，提供了简洁的 API 和丰富的功能。

## 特性

- 基于 Alamofire 和 Moya 构建
- 支持拦截器机制
- 支持缓存管理
- 支持网络日志记录
- 支持自定义重定向处理
- 支持自定义服务器信任评估
- 支持动态基础 URL
- 支持 Combine 框架
- 支持协程
- 支持网络可达性检测
- 支持可自定义的加载指示器管理
- 支持 SwiftProtobuf（可选）
- 支持 RxSwift（可选）
- **智能重试机制** - 根据错误类型和网络状况自动调整重试策略
- **安全特性** - 支持证书锁定和客户端证书认证
- **性能监控** - 全面的性能监控功能
- **多环境配置管理** - 方便在不同环境间切换
- **离线处理** - 支持离线请求处理和同步
- **国际化支持** - 支持多语言错误消息和日志
- **可访问性支持** - 支持VoiceOver和动态字体大小
- **向后兼容性** - 完善的版本管理机制

## 项目结构

```
FMNetCore/
├── Sources/
│   ├── APIRequest.swift
│   ├── CacheManager.swift
│   ├── Combine+Extensions.swift
│   ├── CustomRedirectHandler.swift
│   ├── CustomServerTrustEvaluator.swift
│   ├── DynamicBaseURL.swift
│   ├── FMNetCore.swift
│   ├── LoadingIndicatorManager.swift
│   ├── NetworkConfig.swift
│   ├── NetworkError.swift
│   ├── NetworkInterceptor.swift
│   ├── NetworkLogger.swift
│   ├── NetworkManager+CombinedRequests.swift
│   ├── NetworkManager+Coroutine.swift
│   ├── NetworkManager.swift
│   ├── NetworkURLSessionDelegate.swift
│   ├── ProtobufSupport.swift
│   ├── ReachabilityManager.swift
│   ├── ResponseHandler.swift
│   ├── RxSwiftSupport.swift
│   ├── SmartRetryStrategy.swift
│   ├── SmartRetryPublisher.swift
│   ├── SecurityManager.swift
│   ├── PerformanceMonitor.swift
│   ├── EnvironmentManager.swift
│   ├── OfflineRequestManager.swift
│   ├── LocalizationManager.swift
│   ├── VersionManager.swift
│   └── Resources/
│       ├── en.lproj/
│       │   └── Localizable.strings
│       └── zh-Hans.lproj/
│           └── Localizable.strings
├── Tests/
│   ├── CacheManagerTests.swift
│   ├── CodeQualityTests.swift
│   ├── DynamicBaseURLTests.swift
│   ├── NetworkManagerTests.swift
│   ├── NetworkURLSessionDelegateTests.swift
│   ├── NetworkingTests.swift
│   ├── ProxyConfigTests.swift
│   ├── ReachabilityManagerTests.swift
│   ├── SmartRetryTests.swift
│   ├── PerformanceMonitorTests.swift
│   ├── EnvironmentManagerTests.swift
│   ├── OfflineRequestManagerTests.swift
│   ├── LocalizationManagerTests.swift
│   └── VersionManagerTests.swift
├── Documentation/
│   ├── APIReference.md
│   ├── AdvancedUsage.md
│   ├── GettingStarted.md
│   ├── MigrationGuide.md
│   └── Troubleshooting.md
├── Examples/
│   ├── SimpleExample.swift
│   ├── ExampleApp/
│   │   ├── Package.swift
│   │   ├── README.md
│   │   └── Sources/
│   │       └── ExampleApp/
│   │           └── main.swift
│   └── iOSExample/
│       └── iOSExample/
│           ├── Package.swift
│           ├── AppDelegate.swift
│           ├── ProtobufExample.swift
│           ├── RxSwiftExample.swift
│           ├── ViewController.swift
│           ├── ExampleAPIRequests.swift
│           ├── CustomLoadingIndicatorExample.swift
│           ├── NetworkExamplesViewController.swift
│           ├── NetworkLogViewController.swift
│           ├── NetworkSimulation.swift
│           ├── CacheStatsViewController.swift
│           ├── WeakNetworkMonitorViewController.swift
│           ├── WeakNetworkTestViewController.swift
│           ├── WeakNetworkUsageExample.swift
│           ├── SmartRetryExample.swift
│           ├── SecurityExample.swift
│           ├── PerformanceMonitorExample.swift
│           ├── EnvironmentManagerExample.swift
│           ├── OfflineHandlingExample.swift
│           ├── LocalizationExample.swift
│           ├── AccessibilityExample.swift
│           └── VersionManagementExample.swift
├── scripts/
│   ├── setup.sh
│   ├── run-example.sh
│   ├── run-ios-example.sh
│   ├── generate-docs.sh
│   └── release.sh
├── Package.swift
├── FMNetCore.podspec
├── README.md
├── CHANGELOG.md
├── LICENSE
└── CONTRIBUTING.md
```

## 安装

### Swift Package Manager

在 Xcode 中，选择 File > Swift Packages > Add Package Dependency，然后输入以下 URL：

```
https://github.com/fengmingdev/FMNetCore.git
```

或者在 Package.swift 文件中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/fengmingdev/FMNetCore.git", from: "1.0.0")
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

## 快速开始

### 使用脚本设置开发环境

```bash
./scripts/setup.sh
```

### 运行示例应用

```bash
./scripts/run-example.sh
```

### 运行iOS示例

```bash
./scripts/run-example.sh ios
```

或者

```bash
./scripts/run-ios-example.sh
```

## 使用方法

### 基本用法

```swift
import FMNetCore

let networkManager = NetworkManager.shared

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

### 创建自定义 API

```swift
public enum MyAPI {
    case getUser(id: Int)
    case createUser(user: User)
}

extension MyAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.example.com")!
    }
    
    public var path: String {
        switch self {
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUser:
            return .get
        case .createUser:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .getUser:
            return .requestPlain
        case .createUser(let user):
            return .requestJSONEncodable(user)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
```

### 配置网络管理器

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.timeoutInterval = 20.0
config.enableLogging = true
config.maxRetryCount = 3

let networkManager = NetworkManager(config: config)
```

### 使用拦截器

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

### 自定义加载指示器

```swift
// 创建自定义加载指示器
class CustomLoadingIndicator: LoadingIndicator {
    func show() {
        // 显示自定义加载视图
        DispatchQueue.main.async {
            // 在主线程中显示您的自定义加载视图
        }
    }
    
    func hide() {
        // 隐藏自定义加载视图
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

// 设置自定义加载指示器
LoadingIndicatorManager.shared.setIndicator(CustomLoadingIndicator())

// 配置加载指示器延迟
let config = LoadingIndicatorConfig(
    showDelay: 0.3, 
    hideDelay: 0.1,
    preventDuplicateShow: true,
    minimumDisplayTime: 0.1
)
LoadingIndicatorManager.shared.configure(with: config)
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

### 智能重试机制

FMNetCore 提供了智能重试机制，可以根据错误类型和网络状况自动调整重试策略：

```swift
// 使用自定义重试策略
let exponentialStrategy = ExponentialBackoffRetryStrategy(baseDelay: 1.0, maxDelay: 60.0, multiplier: 2.0)
let adaptiveStrategy = AdaptiveRetryStrategy(exponentialStrategy: exponentialStrategy)

// 设置全局重试策略
NetworkManager.shared.setRetryStrategy(adaptiveStrategy)

// 或者为特定请求设置重试策略
struct CustomRequest: APIRequest {
    typealias Target = MyAPI
    
    func asTarget() -> MyAPI {
        return .getData
    }
    
    var retryStrategy: RetryStrategy? {
        return CustomRetryStrategy()
    }
    
    var retryCount: Int? {
        return 5
    }
}
```

### 安全特性

FMNetCore 提供了完善的安全特性，包括证书锁定和客户端证书认证：

```swift
// 配置证书锁定
var securityConfig = SecurityConfig()
securityConfig.enableCertificatePinning = true
securityConfig.certificatePinningMode = .publicKey
securityConfig.certificatePaths = ["path/to/certificate.cer"]

SecurityManager.shared.configure(with: securityConfig)

// 配置客户端证书认证
var securityConfig = SecurityConfig()
securityConfig.enableClientCertificateAuthentication = true
securityConfig.clientCertificatePath = "path/to/client-certificate.p12"
securityConfig.clientCertificatePassword = "certificate-password"

SecurityManager.shared.configure(with: securityConfig)
```

### 性能监控

FMNetCore 提供了全面的性能监控功能，帮助您优化网络请求性能：

```swift
// 配置性能监控
var performanceConfig = PerformanceMonitorConfig()
performanceConfig.enabled = true
performanceConfig.detailedMetrics = true
performanceConfig.logLevel = .verbose
performanceConfig.performanceThreshold = 3000 // 3秒阈值

PerformanceMonitor.shared.configure(with: performanceConfig)

// 获取性能指标
let allMetrics = PerformanceMonitor.shared.getAllMetrics()
let overThresholdMetrics = PerformanceMonitor.shared.getOverThresholdMetrics()
let stats = PerformanceMonitor.shared.getPerformanceStats()
```

### 多环境配置管理

FMNetCore 支持多环境配置管理，方便在不同环境间切换：

```swift
// 添加自定义环境配置
let customConfig = EnvironmentConfig(
    type: .staging,
    baseURL: URL(string: "https://staging.api.example.com")!,
    apiVersion: "v1",
    timeoutInterval: 20.0,
    enableLogging: true,
    logLevel: .info,
    maxRetryCount: 2,
    enableCache: true,
    customConfig: ["staging": true]
)

EnvironmentManager.shared.addConfig(customConfig, for: .staging)

// 切换到特定环境
EnvironmentManager.shared.setCurrentEnvironment(.staging)
```

### 离线处理

FMNetCore 支持离线请求处理，确保在网络恢复后自动同步请求：

```swift
// 获取离线请求统计信息
let stats = OfflineRequestManager.shared.getStats()

// 同步离线请求
OfflineRequestManager.shared.syncOfflineRequests()

// 清除已完成的请求
OfflineRequestManager.shared.removeCompletedRequests()
```

### 国际化支持

FMNetCore 提供了完整的国际化支持，支持多语言错误消息和日志：

```swift
// 切换到中文
LocalizationManager.shared.switchLanguage(to: "zh-Hans")

// 切换到英文
LocalizationManager.shared.switchLanguage(to: "en")

// 获取本地化错误消息
let errorMessage = NetworkError.timeout.localizedDescription

// 获取自定义本地化字符串
let customMessage = LocalizationManager.shared.localizedString(for: "custom.key", defaultValue: "Default Value")
```

### 可访问性支持

FMNetCore 支持VoiceOver和动态字体大小，确保应用对所有用户都可访问：

```swift
// 检查VoiceOver是否运行
if UIAccessibility.isVoiceOverRunning {
    // VoiceOver正在运行
}

// 使用VoiceOver朗读文本
UIAccessibility.post(notification: .announcement, argument: "可访问的文本")
```

### 向后兼容性

FMNetCore 提供了完善的版本管理机制，确保API的向后兼容性：

```swift
// 设置当前API版本
VersionManager.shared.setCurrentAPIVersion(.v2)

// 废弃特定版本
VersionManager.shared.deprecateVersion(.v1)

// 获取API端点URL
let endpoint = VersionManager.shared.getAPIEndpoint(basePath: "https://api.example.com/")

// 实现版本化API请求
struct VersionedRequest: VersionedAPIRequest {
    typealias Target = MyAPI
    
    func asTarget() -> MyAPI {
        return .getData
    }
    
    var apiVersion: APIVersion? {
        return .v2
    }
}
```

### 使用 SwiftProtobuf（可选）

FMNetCore 支持使用 SwiftProtobuf 进行高效的序列化。要使用此功能，需要在项目中添加 SwiftProtobuf 依赖：

```swift
// 定义 Protobuf 请求
struct GetUserProtobufRequest: ProtobufAPIRequest {
    typealias Target = UserAPI
    typealias RequestMessage = UserRequest
    typealias ResponseMessage = UserResponse
    
    let userId: Int
    
    func buildRequestMessage() -> UserRequest? {
        let request = UserRequest()
        request.id = Int32(userId)
        return request
    }
    
    func parseResponseMessage(from data: Data) throws -> UserResponse {
        return try UserResponse(serializedData: data)
    }
}
```

### 使用 RxSwift（可选）

FMNetCore 也支持 RxSwift 进行响应式编程。要使用此功能，需要在项目中添加 RxSwift 依赖：

```swift
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
        }
    )
    .disposed(by: disposeBag)
```

## 文档

详细的文档可以在 [Documentation](Documentation/) 目录中找到：

- [入门指南](Documentation/GettingStarted.md)
- [高级用法](Documentation/AdvancedUsage.md)
- [API 参考](Documentation/APIReference.md)
- [迁移指南](Documentation/MigrationGuide.md)
- [故障排除](Documentation/Troubleshooting.md)
- [开发规则](RULES.md)

## 示例

FMNetCore 提供了多种示例来帮助您快速上手：

1. [SimpleExample.swift](Examples/SimpleExample.swift) - 简单的使用示例
2. [ExampleApp](Examples/ExampleApp/) - 命令行示例应用
3. [iOSExample](Examples/iOSExample/) - iOS 应用示例，包含可执行的应用target

## 贡献

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

## 许可证

FMNetCore 使用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。