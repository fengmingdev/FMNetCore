# 高级用法

## 智能重试机制

FMNetCore 提供了智能重试机制，可以根据错误类型和网络状况自动调整重试策略。

### 重试策略

FMNetCore 提供了多种重试策略：

1. **指数退避重试策略** (`ExponentialBackoffRetryStrategy`)
2. **自适应重试策略** (`AdaptiveRetryStrategy`)

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

## 安全特性

FMNetCore 提供了完善的安全特性，包括证书锁定和客户端证书认证。

### 证书锁定

``swift
// 配置证书锁定
var securityConfig = SecurityConfig()
securityConfig.enableCertificatePinning = true
securityConfig.certificatePinningMode = .publicKey
securityConfig.certificatePaths = ["path/to/certificate.cer"]

SecurityManager.shared.configure(with: securityConfig)
```

### 客户端证书认证

``swift
// 配置客户端证书认证
var securityConfig = SecurityConfig()
securityConfig.enableClientCertificateAuthentication = true
securityConfig.clientCertificatePath = "path/to/client-certificate.p12"
securityConfig.clientCertificatePassword = "certificate-password"

SecurityManager.shared.configure(with: securityConfig)
```

## 性能监控

FMNetCore 提供了全面的性能监控功能，帮助您优化网络请求性能。

### 配置性能监控

``swift
// 配置性能监控
var performanceConfig = PerformanceMonitorConfig()
performanceConfig.enabled = true
performanceConfig.detailedMetrics = true
performanceConfig.logLevel = .verbose
performanceConfig.performanceThreshold = 3000 // 3秒阈值

PerformanceMonitor.shared.configure(with: performanceConfig)
```

### 查看性能指标

``swift
// 获取所有性能指标
let allMetrics = PerformanceMonitor.shared.getAllMetrics()

// 获取超阈值的性能指标
let overThresholdMetrics = PerformanceMonitor.shared.getOverThresholdMetrics()

// 获取性能统计信息
let stats = PerformanceMonitor.shared.getPerformanceStats()
```

## 多环境配置管理

FMNetCore 支持多环境配置管理，方便在不同环境间切换。

### 配置环境

``swift
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

## 离线处理

FMNetCore 支持离线请求处理，确保在网络恢复后自动同步请求。

### 离线请求管理

``swift
// 获取离线请求统计信息
let stats = OfflineRequestManager.shared.getStats()

// 同步离线请求
OfflineRequestManager.shared.syncOfflineRequests()

// 清除已完成的请求
OfflineRequestManager.shared.removeCompletedRequests()
```

## 国际化支持

FMNetCore 提供了完整的国际化支持，支持多语言错误消息和日志。

### 切换语言

``swift
// 切换到中文
LocalizationManager.shared.switchLanguage(to: "zh-Hans")

// 切换到英文
LocalizationManager.shared.switchLanguage(to: "en")
```

### 获取本地化字符串

``swift
// 获取本地化错误消息
let errorMessage = NetworkError.timeout.localizedDescription

// 获取自定义本地化字符串
let customMessage = LocalizationManager.shared.localizedString(for: "custom.key", defaultValue: "Default Value")
```

## 可访问性支持

FMNetCore 支持VoiceOver和动态字体大小，确保应用对所有用户都可访问。

### VoiceOver支持

``swift
// 检查VoiceOver是否运行
if UIAccessibility.isVoiceOverRunning {
    // VoiceOver正在运行
}

// 使用VoiceOver朗读文本
UIAccessibility.post(notification: .announcement, argument: "可访问的文本")
```

### 动态字体大小

``swift
// 支持动态字体大小的UI元素会自动适配系统设置
label.font = UIFont.preferredFont(forTextStyle: .body)
```

## 向后兼容性

FMNetCore 提供了完善的版本管理机制，确保API的向后兼容性。

### 版本管理

``swift
// 设置当前API版本
VersionManager.shared.setCurrentAPIVersion(.v2)

// 废弃特定版本
VersionManager.shared.deprecateVersion(.v1)

// 获取API端点URL
let endpoint = VersionManager.shared.getAPIEndpoint(basePath: "https://api.example.com/")
```

### 版本化请求

``swift
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

## 自定义拦截器

除了内置的拦截器，您还可以创建自定义拦截器来处理特定的业务逻辑。

### 创建自定义拦截器

``swift
class CustomInterceptor: NetworkInterceptor {
    func willSendRequest(_ request: Any, target: TargetType) {
        // 请求发送前的处理
        NetworkLogger.shared.log(.info, message: "CustomInterceptor: 请求即将发送")
    }
    
    func didCompleteRequest(_ request: Any, target: TargetType, result: Result<Response, MoyaError>) {
        // 请求完成后的处理
        NetworkLogger.shared.log(.info, message: "CustomInterceptor: 请求已完成")
    }
    
    func didSucceedRequest(_ request: Any, target: TargetType, response: Response) {
        // 请求成功后的处理
        NetworkLogger.shared.log(.info, message: "CustomInterceptor: 请求成功")
    }
    
    func didFailRequest(_ request: Any, target: TargetType, error: MoyaError) {
        // 请求失败后的处理
        NetworkLogger.shared.log(.error, message: "CustomInterceptor: 请求失败 - \(error)")
    }
}

// 添加自定义拦截器
NetworkInterceptorManager.shared.addInterceptor(CustomInterceptor())
```

## 自定义加载指示器

您可以创建自定义的加载指示器来匹配应用的设计风格。

### 创建自定义加载指示器

``swift
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
    
    // 实现可选的生命周期回调方法
    func willShow() {
        print("CustomLoadingIndicator will show")
    }
    
    func didShow() {
        print("CustomLoadingIndicator did show")
    }
    
    func willHide() {
        print("CustomLoadingIndicator will hide")
    }
    
    func didHide() {
        print("CustomLoadingIndicator did hide")
    }
}

// 设置自定义加载指示器
LoadingIndicatorManager.shared.setIndicator(CustomLoadingIndicator())
```

## 缓存策略

FMNetCore 提供了灵活的缓存策略，可以根据需要选择合适的缓存方式。

### 使用缓存

``swift
// 发送带缓存的请求
NetworkManager.shared.request(User.self, GetUserRequest(userId: 1), useCache: true)

// 清除缓存
CacheManager.shared.clearAllCache()

// 获取缓存统计信息
let cacheStats = CacheManager.shared.getCacheStats()
print("缓存命中率: \(cacheStats.hitRate)")
```

## 网络状态监测

FMNetCore 提供了网络状态监测功能，可以实时获取网络连接状态。

### 监测网络状态

``swift
// 订阅网络状态变化
ReachabilityManager.shared.$networkStatus
    .sink { status in
        switch status {
        case .unreachable:
            print("网络不可达")
        case .wifi:
            print("WiFi连接")
        case .cellular(let quality):
            print("蜂窝网络质量: \(quality)")
        }
    }
    .store(in: &cancellables)
```

通过这些高级功能，FMNetCore 可以满足各种复杂的网络需求，帮助您构建更强大、更可靠的网络应用。