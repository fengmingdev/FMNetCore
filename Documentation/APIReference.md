# API 参考

## NetworkManager

网络管理器是 FMNetCore 的核心组件，负责处理所有的网络请求。

### 初始化

```swift
// 单例实例
static let shared: NetworkManager

// 自定义初始化
init(config: NetworkConfig = NetworkConfig(baseURL: URL(string: "https://api.example.com")!))
```

### 属性

- `config: NetworkConfig` - 网络配置
- `provider: MoyaProvider<MultiTarget>` - Moya 提供者
- `cancellables: Set<AnyCancellable>` - 存储订阅
- `cacheManager: CacheManager` - 缓存管理器
- `interceptorManager: NetworkInterceptorManager` - 拦截器管理器

### 方法

#### request(_:)

发送网络请求。

```swift
func request<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError>
```

#### request(_:useCache:)

发送网络请求，支持缓存。

```swift
func request<T: Decodable, R: APIRequest>(_ request: R, useCache: Bool) -> AnyPublisher<T, NetworkError>
```

#### requestWithLoading(_:)

发送网络请求并显示加载指示器。

```swift
func requestWithLoading<T: Decodable, R: APIRequest>(_ request: R) -> AnyPublisher<T, NetworkError>
```

#### setRetryStrategy(_:)

设置重试策略。

```swift
func setRetryStrategy(_ strategy: RetryStrategy)
```

#### getRetryStrategy()

获取当前重试策略。

```swift
func getRetryStrategy() -> RetryStrategy
```

## NetworkConfig

网络配置用于配置 NetworkManager 的行为。

### 属性

- `baseURL: URL` - 基础URL
- `headers: [String: String]` - 全局请求头
- `timeoutInterval: TimeInterval` - 超时时间
- `enableLogging: Bool` - 是否开启日志
- `maxRetryCount: Int` - 最大重试次数
- `retryInterval: TimeInterval` - 重试间隔
- `slowNetworkThreshold: TimeInterval` - 弱网判断阈值
- `logFilePath: String?` - 日志文件路径
- `logRequestBody: Bool` - 是否记录请求体
- `logResponseBody: Bool` - 是否记录响应体
- `proxyConfig: ProxyConfig?` - 代理配置
- `allowRedirects: Bool` - 是否允许HTTP重定向
- `maxRedirects: Int` - 最大重定向次数
- `sslCertificatePath: String?` - SSL证书锁定配置文件路径
- `allowInvalidCertificates: Bool` - 是否允许无效SSL证书
- `securityConfig: SecurityConfig` - 安全配置

## APIRequest 协议

API请求协议定义了网络请求的接口规范。

### 关联类型

- `Target: TargetType` - 对应的Moya TargetType

### 方法

#### asTarget()

构建TargetType实例。

```swift
func asTarget() -> Target
```

### 属性

- `timeoutInterval: TimeInterval?` - 请求超时时间
- `allowsWeakNetwork: Bool` - 是否允许弱网环境下请求
- `retryCount: Int?` - 重试次数
- `needsLoadingIndicator: Bool` - 是否需要显示加载指示器
- `retryStrategy: RetryStrategy?` - 自定义重试策略

## VersionedAPIRequest 协议

支持版本管理的API请求协议。

### 属性

- `apiVersion: APIVersion?` - API版本

## NetworkError 枚举

网络错误枚举定义了所有可能的网络错误。

### 成员

- `invalidURL` - 无效URL
- `noData` - 无数据返回
- `decodingError(error: DecodingError)` - 数据解码失败
- `serverError(Int)` - 服务器错误
- `httpError(code: Int)` - HTTP错误
- `sslCertificateVerificationFailed` - SSL证书验证失败
- `unknown` - 未知错误
- `weakNetwork` - 弱网环境下的错误
- `timeout` - 超时错误
- `networkUnreachable` - 网络不可达
- `weakNetworkNotAllowed` - 弱网不被允许
- `parsingError` - 解析错误
- `other(error: Error)` - 自定义错误

## RetryStrategy 协议

重试策略协议定义了重试行为。

### 方法

#### calculateRetryDelay(for:with:)

计算重试延迟时间。

```swift
func calculateRetryDelay(for attempt: Int, with error: NetworkError) -> TimeInterval
```

#### shouldRetry(for:maxRetries:with:)

判断是否应该重试。

```swift
func shouldRetry(for attempt: Int, maxRetries: Int, with error: NetworkError) -> Bool
```

## ExponentialBackoffRetryStrategy

指数退避重试策略。

### 初始化

```swift
init(baseDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 60.0, multiplier: Double = 2.0)
```

## AdaptiveRetryStrategy

自适应重试策略。

### 初始化

```swift
init(
    exponentialStrategy: ExponentialBackoffRetryStrategy = ExponentialBackoffRetryStrategy(),
    networkStatusProvider: @escaping () -> NetworkStatus = { ReachabilityManager.shared.networkStatus }
)
```

## SecurityManager

安全管理器负责处理网络安全性相关配置。

### 属性

- `static let shared: SecurityManager` - 单例实例

### 方法

#### configure(with:)

配置安全设置。

```swift
func configure(with config: SecurityConfig)
```

#### getCurrentConfig()

获取当前安全配置。

```swift
func getCurrentConfig() -> SecurityConfig
```

#### validateServerCertificate(_:forHost:)

验证服务器证书。

```swift
func validateServerCertificate(_ serverTrust: SecTrust, forHost host: String) -> Bool
```

## PerformanceMonitor

性能监控管理器负责监控网络请求性能。

### 属性

- `static let shared: PerformanceMonitor` - 单例实例

### 方法

#### configure(with:)

配置性能监控。

```swift
func configure(with config: PerformanceMonitorConfig)
```

#### getCurrentConfig()

获取当前配置。

```swift
func getCurrentConfig() -> PerformanceMonitorConfig
```

#### startMonitoring(requestId:url:method:)

开始监控请求。

```swift
func startMonitoring(requestId: String, url: String, method: String) -> Date
```

#### endMonitoring(requestId:url:method:startTime:dataSize:)

结束监控请求。

```swift
func endMonitoring(requestId: String, url: String, method: String, startTime: Date, dataSize: Int = 0)
```

#### getAllMetrics()

获取所有性能指标。

```swift
func getAllMetrics() -> [PerformanceMetrics]
```

#### getOverThresholdMetrics()

获取超阈值的性能指标。

```swift
func getOverThresholdMetrics() -> [PerformanceMetrics]
```

#### clearAllMetrics()

清除所有性能指标。

```swift
func clearAllMetrics()
```

#### getPerformanceStats()

获取性能统计信息。

```swift
func getPerformanceStats() -> PerformanceStats
```

## EnvironmentManager

环境管理器负责管理不同环境的配置。

### 属性

- `static let shared: EnvironmentManager` - 单例实例

### 方法

#### addConfig(_:for:)

添加环境配置。

```swift
func addConfig(_ config: EnvironmentConfig, for environment: EnvironmentType)
```

#### getConfig(for:)

获取环境配置。

```swift
func getConfig(for environment: EnvironmentType) -> EnvironmentConfig?
```

#### setCurrentEnvironment(_:)

设置当前环境。

```swift
func setCurrentEnvironment(_ environment: EnvironmentType)
```

#### getCurrentEnvironment()

获取当前环境。

```swift
func getCurrentEnvironment() -> EnvironmentType
```

#### getCurrentConfig()

获取当前环境配置。

```swift
func getCurrentConfig() -> EnvironmentConfig?
```

#### getAllConfigs()

获取所有环境配置。

```swift
func getAllConfigs() -> [EnvironmentType: EnvironmentConfig]
```

## OfflineRequestManager

离线请求管理器负责处理离线请求。

### 属性

- `static let shared: OfflineRequestManager` - 单例实例

### 方法

#### addRequest(_:)

添加离线请求。

```swift
func addRequest(_ request: OfflineRequest)
```

#### updateRequestStatus(_:to:errorMessage:)

更新离线请求状态。

```swift
func updateRequestStatus(_ requestId: String, to status: OfflineRequestStatus, errorMessage: String? = nil)
```

#### getAllRequests()

获取所有离线请求。

```swift
func getAllRequests() -> [OfflineRequest]
```

#### getPendingRequests()

获取待同步的离线请求。

```swift
func getPendingRequests() -> [OfflineRequest]
```

#### removeCompletedRequests()

删除已完成的请求。

```swift
func removeCompletedRequests()
```

#### clearAllRequests()

清除所有请求。

```swift
func clearAllRequests()
```

#### syncOfflineRequests()

同步离线请求。

```swift
func syncOfflineRequests()
```

#### getStats()

获取统计信息。

```swift
func getStats() -> OfflineRequestStats
```

## LocalizationManager

本地化管理器负责处理多语言支持。

### 属性

- `static let shared: LocalizationManager` - 单例实例

### 方法

#### localizedString(for:defaultValue:with:)

获取本地化字符串。

```swift
func localizedString(for key: String, defaultValue: String = "", with arguments: CVarArg...) -> String
```

#### switchLanguage(to:)

切换语言。

```swift
func switchLanguage(to languageCode: String)
```

#### currentLanguageCode()

获取当前语言代码。

```swift
func currentLanguageCode() -> String
```

#### supportedLanguages()

获取支持的语言列表。

```swift
func supportedLanguages() -> [String]
```

## VersionManager

版本管理器负责管理API版本。

### 属性

- `static let shared: VersionManager` - 单例实例

### 方法

#### setCurrentAPIVersion(_:)

设置当前API版本。

```swift
func setCurrentAPIVersion(_ version: APIVersion)
```

#### getCurrentAPIVersion()

获取当前API版本。

```swift
func getCurrentAPIVersion() -> APIVersion
```

#### setCompatibilityStrategy(_:)

设置兼容性策略。

```swift
func setCompatibilityStrategy(_ strategy: VersionCompatibilityStrategy)
```

#### getCompatibilityStrategy()

获取兼容性策略。

```swift
func getCompatibilityStrategy() -> VersionCompatibilityStrategy
```

#### deprecateAPI(_:)

标记API为已废弃。

```swift
func deprecateAPI(_ apiName: String)
```

#### deprecateVersion(_:)

标记版本为已废弃。

```swift
func deprecateVersion(_ version: APIVersion)
```

#### isAPI_DEPRECATED(_:)

检查API是否已废弃。

```swift
func isAPI_DEPRECATED(_ apiName: String) -> Bool
```

#### isVersion_DEPRECATED(_:)

检查版本是否已废弃。

```swift
func isVersion_DEPRECATED(_ version: APIVersion) -> Bool
```

#### getAPIEndpoint(basePath:version:)

获取API端点URL。

```swift
func getAPIEndpoint(basePath: String, version: APIVersion? = nil) -> String
```

#### getCompatibilityReport()

获取版本兼容性报告。

```swift
func getCompatibilityReport() -> VersionCompatibilityReport
```

## CacheManager

缓存管理器负责处理网络请求缓存。

### 属性

- `static let shared: CacheManager` - 单例实例

### 方法

#### setMemoryCache(_:forKey:expiry:cacheType:)

存储数据到内存缓存。

```swift
func setMemoryCache(_ data: AnyObject, forKey key: String, expiry: TimeInterval = 300, cacheType: CacheType = .memory)
```

#### getMemoryCache(forKey:)

从内存缓存获取数据。

```swift
func getMemoryCache(forKey key: String) -> AnyObject?
```

#### setDiskCache(_:forKey:expiry:cacheType:)

存储数据到磁盘缓存。

```swift
func setDiskCache(_ data: Data, forKey key: String, expiry: TimeInterval = 3600, cacheType: CacheType = .disk)
```

#### getDiskCache(forKey:)

从磁盘缓存获取数据。

```swift
func getDiskCache(forKey key: String) -> Data?
```

#### clearAllCache()

清除所有缓存。

```swift
func clearAllCache()
```

#### getCacheStats()

获取缓存统计信息。

```swift
func getCacheStats() -> CacheStats
```

## LoadingIndicatorManager

加载指示器管理器负责管理加载指示器。

### 属性

- `static let shared: LoadingIndicatorManager` - 单例实例

### 方法

#### configure(with:)

配置加载指示器。

```swift
func configure(with config: LoadingIndicatorConfig)
```

#### setIndicator(_:)

设置自定义加载指示器。

```swift
func setIndicator(_ indicator: LoadingIndicator)
```

#### showLoading()

显示加载视图。

```swift
func showLoading() -> UUID
```

#### hideLoading(for:)

隐藏加载视图。

```swift
func hideLoading(for taskId: UUID? = nil)
```

## NetworkInterceptorManager

网络拦截器管理器负责管理网络拦截器。

### 属性

- `static let shared: NetworkInterceptorManager` - 单例实例

### 方法

#### addInterceptor(_:)

添加拦截器。

```swift
func addInterceptor(_ interceptor: NetworkInterceptor)
```

#### removeInterceptor(_:)

移除拦截器。

```swift
func removeInterceptor(_ interceptor: NetworkInterceptor)
```

## ReachabilityManager

网络可达性管理器负责监测网络状态。

### 属性

- `static let shared: ReachabilityManager` - 单例实例
- `@Published var networkStatus: NetworkStatus` - 网络状态

### 方法

#### startMonitoring()

启动网络监测。

```swift
func startMonitoring()
```

#### stopMonitoring()

停止网络监测。

```swift
func stopMonitoring()
```