# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- LoadingIndicator 协议增强，添加了 willShow、didShow、willHide、didHide 回调方法
- LoadingIndicatorConfig 结构体增强，添加了 preventDuplicateShow 和 minimumDisplayTime 配置选项
- LoadingIndicatorManager 增强功能：
  - 添加任务ID跟踪机制，支持精确控制加载指示器的显示和隐藏
  - 添加 isVisible() 方法检查加载指示器是否可见
  - 添加 getLoadingCount() 方法获取当前加载任务数量
  - 添加 getCurrentConfig() 方法获取当前配置
  - 添加 getAllTasks() 方法获取所有加载任务信息
  - 添加 cancelAllLoading() 方法取消所有加载指示器
  - 添加 cancelLoading(for:) 方法取消特定任务的加载指示器
- LoadingIndicatorManager 性能优化：
  - 减少不必要的 DispatchQueue 调用
  - 优化默认加载指示器的实现，避免在非主线程执行UI操作
  - 使用专门的UI队列处理UI更新
  - 添加防重复显示机制
  - 添加最小显示时间配置，防止加载指示器闪烁
- iOS 示例应用中添加增强的自定义加载指示器示例
- 在 README.md 和 Documentation/AdvancedUsage.md 中添加增强功能的使用说明

### Changed
- 重构 LoadingIndicatorManager 以支持外部自定义
- 更新 git repository URL 到 https://github.com/fengmingdev/FMNetCore
- iOSExample 现在使用 CocoaPods 而不是 Swift Package Manager 进行依赖管理
- 添加 Podfile 用于 iOSExample 项目

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [1.0.0] - 2025-09-12

### Added
- Initial release of FMNetCore
- NetworkManager for handling HTTP requests
- NetworkInterceptor for custom request/response processing
- CacheManager for caching responses
- NetworkLogger for logging network requests and responses
- CustomRedirectHandler for handling redirects
- CustomServerTrustEvaluator for custom server trust evaluation
- DynamicBaseURL for dynamic base URL support
- Combine extensions for reactive programming
- Coroutine support for async/await-like syntax
- ReachabilityManager for network reachability detection
- LoadingIndicatorManager for managing loading indicators
- Comprehensive test suite
- Example API requests
- Documentation
- Development rules documentation to avoid recurring issues
- CocoaPods support with FMNetCore.podspec