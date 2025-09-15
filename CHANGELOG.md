# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SwiftProtobuf 支持，包括 ProtobufAPIRequest 协议和 ProtobufResponseHandler
- RxSwift 支持，包括 rxRequest、rxRequestWithLoading、rxCombinedRequest 等扩展方法
- ProtobufSupport.swift 文件提供 Protobuf 相关功能
- RxSwiftSupport.swift 文件提供 RxSwift 相关功能
- iOS 示例应用中添加 Protobuf 和 RxSwift 示例文件
- 在 Package.swift 中添加 SwiftProtobuf 和 RxSwift 依赖
- 在 FMNetCore.podspec 中添加 SwiftProtobuf 和 RxSwift 依赖
- 在 Examples/iOSExample/Podfile 中添加 SwiftProtobuf 和 RxSwift 依赖
- 在 FMNetCore.swift 中添加条件导入 SwiftProtobuf 和 RxSwift
- 在 README.md 中添加 SwiftProtobuf 和 RxSwift 使用说明

### Changed
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