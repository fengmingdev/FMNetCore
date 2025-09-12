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
- 支持加载指示器管理

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
│   ├── ReachabilityManager.swift
│   └── ResponseHandler.swift
├── Tests/
│   ├── CacheManagerTests.swift
│   ├── CodeQualityTests.swift
│   ├── DynamicBaseURLTests.swift
│   ├── NetworkManagerTests.swift
│   ├── NetworkURLSessionDelegateTests.swift
│   ├── NetworkingTests.swift
│   ├── ProxyConfigTests.swift
│   └── ReachabilityManagerTests.swift
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
│           ├── ViewController.swift
│           └── 其他示例文件
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