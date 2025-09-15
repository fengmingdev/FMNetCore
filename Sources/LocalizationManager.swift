//
//  LocalizationManager.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation

/// 本地化管理器
public final class LocalizationManager {
    public static let shared = LocalizationManager()
    
    private var bundle: Bundle?
    private let queue = DispatchQueue(label: "com.fmnetcore.localization", qos: .utility)
    
    private init() {
        setupLocalization()
    }
    
    /// 设置本地化
    private func setupLocalization() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 获取当前应用的语言
            let language = Locale.current.languageCode ?? "en"
            
            // 尝试加载对应的本地化资源包
            if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                self.bundle = bundle
            } else {
                // 如果没有找到对应的语言包，使用默认的主bundle
                self.bundle = Bundle.main
            }
        }
    }
    
    /// 获取本地化字符串
    /// - Parameters:
    ///   - key: 字符串键
    ///   - defaultValue: 默认值
    ///   - arguments: 格式化参数
    /// - Returns: 本地化字符串
    public func localizedString(
        for key: String,
        defaultValue: String = "",
        with arguments: CVarArg...
    ) -> String {
        let value = queue.sync { bundle?.localizedString(forKey: key, value: defaultValue, table: nil) ?? defaultValue }
        
        if arguments.isEmpty {
            return value
        } else {
            return String(format: value, arguments: arguments)
        }
    }
    
    /// 切换语言
    /// - Parameter languageCode: 语言代码（如"en"、"zh-Hans"等）
    public func switchLanguage(to languageCode: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 尝试加载对应的本地化资源包
            if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                self.bundle = bundle
                
                // 通知语言已更改
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
                }
            }
        }
    }
    
    /// 获取当前语言代码
    /// - Returns: 当前语言代码
    public func currentLanguageCode() -> String {
        return queue.sync {
            bundle?.preferredLocalizations.first ?? Locale.current.languageCode ?? "en"
        }
    }
    
    /// 获取支持的语言列表
    /// - Returns: 支持的语言代码数组
    public func supportedLanguages() -> [String] {
        return queue.sync {
            Bundle.main.localizations.filter { $0 != "Base" }
        }
    }
}

/// 本地化字符串键
public enum LocalizationKey: String {
    // 网络错误相关
    case invalidURL = "network.error.invalid_url"
    case noData = "network.error.no_data"
    case decodingError = "network.error.decoding_error"
    case serverError = "network.error.server_error"
    case httpError = "network.error.http_error"
    case sslCertificateVerificationFailed = "network.error.ssl_certificate_verification_failed"
    case unknownError = "network.error.unknown_error"
    case weakNetwork = "network.error.weak_network"
    case timeout = "network.error.timeout"
    case networkUnreachable = "network.error.network_unreachable"
    case weakNetworkNotAllowed = "network.error.weak_network_not_allowed"
    case parsingError = "network.error.parsing_error"
    
    // 网络日志相关
    case requestSending = "network.log.request_sending"
    case requestSuccess = "network.log.request_success"
    case requestFailure = "network.log.request_failure"
    case requestComplete = "network.log.request_complete"
    
    // 加载指示器相关
    case loading = "loading.indicator.loading"
    case loadingComplete = "loading.indicator.complete"
    
    // 缓存相关
    case cacheHit = "cache.hit"
    case cacheMiss = "cache.miss"
    case cacheClear = "cache.clear"
    
    // 性能监控相关
    case performanceSlowRequest = "performance.slow_request"
    case performanceMemoryUsage = "performance.memory_usage"
    case performanceNetworkTraffic = "performance.network_traffic"
}