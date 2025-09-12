# 故障排除

## 常见问题

### 1. 无法解析依赖

如果遇到依赖解析问题，请尝试以下步骤：

1. 删除 .build 目录：
   ```
   rm -rf .build
   ```

2. 重新解析依赖：
   ```
   swift package resolve
   ```

3. 如果仍然有问题，尝试更新依赖版本：
   ```swift
   // 在 Package.swift 中更新依赖版本
   .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
   .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0")
   ```

### 2. 构建失败

如果构建失败，请检查以下几点：

1. 确保所有依赖都已正确解析
2. 检查代码中是否有语法错误
3. 确保使用的 Swift 版本与项目要求一致

### 3. 网络请求失败

如果网络请求失败，请检查以下几点：

1. 确保网络连接正常
2. 检查 URL 是否正确
3. 检查请求头和参数是否正确
4. 查看网络日志以获取更多信息

### 4. 缓存问题

如果遇到缓存相关的问题，请尝试以下步骤：

1. 清除缓存：
   ```swift
   CacheManager.shared.clearCache()
   ```

2. 重新配置缓存：
   ```swift
   let cacheConfig = CacheConfig()
   CacheManager.shared.enableCache(with: cacheConfig)
   ```

## 调试技巧

### 1. 启用详细日志

在开发过程中，启用详细日志可以帮助您诊断问题：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.enableLogging = true
config.logLevel = .verbose  // 启用详细日志

let networkManager = NetworkManager(config: config)
```

### 2. 使用网络代理

在开发过程中，您可以使用网络代理来监控网络请求：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.proxyConfig = ProxyConfig(
    host: "localhost",
    port: 8888,  // Charles Proxy 默认端口
    username: nil,
    password: nil,
    httpEnabled: true,
    httpsEnabled: true
)

let networkManager = NetworkManager(config: config)
```

### 3. 模拟网络条件

您可以模拟不同的网络条件来测试应用的健壮性：

```swift
// 模拟慢速网络
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.slowNetworkThreshold = 5.0  // 5秒

let networkManager = NetworkManager(config: config)
```

## 性能优化

### 1. 优化缓存策略

合理配置缓存可以显著提高应用性能：

```swift
let cacheConfig = CacheConfig()
cacheConfig.maxDiskCacheSize = 50 * 1024 * 1024  // 50MB
cacheConfig.defaultMemoryExpiry = 300  // 5分钟
cacheConfig.defaultDiskExpiry = 3600  // 1小时

CacheManager.shared.enableCache(with: cacheConfig)
```

### 2. 使用连接池

FMNetCore 默认使用连接池来优化网络请求：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.maxConnectionsPerHost = 6  // 默认值

let networkManager = NetworkManager(config: config)
```

### 3. 批量请求

对于多个相关请求，使用批量请求可以减少网络延迟：

```swift
let request1 = GetUserRequest(userId: 1)
let request2 = GetUserPostsRequest(userId: 1)

networkManager.combinedRequest(request1, request2) { result in
    switch result {
    case .success(let (user, posts)):
        // 处理用户和帖子数据
    case .failure(let error):
        // 处理错误
    }
}
```

## 安全考虑

### 1. SSL/TLS 配置

确保正确配置 SSL/TLS 以保护数据传输：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.allowInvalidCertificates = false  // 不允许无效证书
config.validatesCertificateChain = true  // 验证证书链

let networkManager = NetworkManager(config: config)
```

### 2. 敏感信息保护

避免在日志中记录敏感信息：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://api.example.com")!)
config.enableLogging = true
config.logSensitiveData = false  // 不记录敏感数据

let networkManager = NetworkManager(config: config)
```

### 3. 请求头安全

确保敏感的请求头信息得到适当保护：

```swift
class SecureInterceptor: NetworkInterceptor {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var modifiedRequest = request
        // 从安全存储中获取认证令牌
        if let token = KeychainHelper.shared.getAuthToken() {
            modifiedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return modifiedRequest
    }
}
```