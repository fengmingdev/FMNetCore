# API 参考

## NetworkManager

`NetworkManager` 是 FMNetCore 的核心类，负责处理所有网络请求。

### 属性

- `shared`: 单例实例
- `config`: 网络配置
- `provider`: Moya 提供者

### 方法

#### request

发送网络请求。

```swift
func request<T: TargetType>(_ target: T, completion: @escaping (Result<Moya.Response, MoyaError>) -> Void) -> Int
```

#### requestPublisher

返回一个 Combine Publisher，用于响应式编程。

```swift
func requestPublisher<T: TargetType>(_ target: T) -> AnyPublisher<Moya.Response, MoyaError>
```

#### combinedRequest

发送组合请求。

```swift
func combinedRequest<T1: APIRequest, T2: APIRequest>(_ request1: T1, _ request2: T2, completion: @escaping (Result<(T1.ResponseType, T2.ResponseType), Error>) -> Void) -> Int
```

## NetworkConfig

`NetworkConfig` 用于配置网络管理器。

### 属性

- `baseURL`: 基础 URL
- `timeoutInterval`: 超时时间
- `enableLogging`: 是否启用日志
- `maxRetryCount`: 最大重试次数
- `retryInterval`: 重试间隔
- `headers`: 请求头

## NetworkInterceptor

`NetworkInterceptor` 协议定义了拦截器的接口。

### 方法

#### prepare

在请求发送前调用。

```swift
func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
```

#### process

在响应接收后调用。

```swift
func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError>
```

## CacheManager

`CacheManager` 负责管理网络请求的缓存。

### 方法

#### enableCache

启用缓存。

```swift
func enableCache(with config: CacheConfig)
```

#### clearCache

清除缓存。

```swift
func clearCache()
```

## NetworkError

`NetworkError` 枚举定义了常见的网络错误类型。

### 错误类型

- `invalidURL`: 无效的 URL
- `noData`: 没有接收到数据
- `decodingError`: 数据解码错误
- `serverError(Int)`: 服务器错误，包含状态码
- `unknown`: 未知错误

## 示例 API 请求

### ExampleAPIRequests

`ExampleAPIRequests` 包含了一些示例 API 请求。

#### 枚举值

- `getUsers`: 获取所有用户
- `getUser(id: Int)`: 获取指定 ID 的用户
- `getPosts`: 获取所有帖子
- `getPost(id: Int)`: 获取指定 ID 的帖子