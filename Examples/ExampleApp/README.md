# FMNetCore 示例应用

这个示例应用展示了如何使用 FMNetCore 进行各种网络请求。

## 功能演示

1. **基本 GET 请求**: 获取用户列表
2. **带参数的 GET 请求**: 获取特定用户
3. **POST 请求**: 创建新用户
4. **Combine 框架**: 使用 Combine 进行响应式编程
5. **组合请求**: 同时发送多个请求

## 运行示例

### 使用 Swift Package Manager

```bash
cd /Users/fengming/Desktop/Networking/FMNetCore/Examples/ExampleApp
swift run
```

### 使用 Xcode

1. 生成 Xcode 项目:
   ```bash
   cd /Users/fengming/Desktop/Networking/FMNetCore/Examples/ExampleApp
   swift package generate-xcodeproj
   ```

2. 打开生成的 `.xcodeproj` 文件

3. 选择目标设备并运行

## 代码结构

- `main.swift`: 主程序文件，包含所有示例代码
- `Package.swift`: Swift Package Manager 配置文件

## 示例说明

### 1. 基本 GET 请求

演示如何发送简单的 GET 请求来获取数据。

### 2. 带参数的 GET 请求

演示如何发送带参数的 GET 请求。

### 3. POST 请求

演示如何发送 POST 请求来创建新资源。

### 4. Combine 框架

演示如何使用 Combine 框架进行响应式编程。

### 5. 组合请求

演示如何同时发送多个请求并处理组合结果。

## 自定义配置

您可以通过修改 `main.swift` 中的 `NetworkConfig` 来自定义网络配置：

```swift
var config = NetworkConfig(baseURL: URL(string: "https://your-api.com")!)
config.timeoutInterval = 20.0
config.enableLogging = true
config.maxRetryCount = 3
```

## 拦截器

示例应用展示了如何使用自定义拦截器来处理请求和响应：

```swift
class LoggingInterceptor: NetworkInterceptor {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        print("Sending request to \(request.url?.absoluteString ?? "")")
        return request
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        // 处理响应
        return result
    }
}
```