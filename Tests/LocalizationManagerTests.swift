//
//  LocalizationManagerTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/15.
//

import XCTest
@testable import FMNetCore

class LocalizationManagerTests: XCTestCase {
    
    func testLocalizationManagerInitialization() {
        let manager = LocalizationManager.shared
        
        // 测试初始化
        XCTAssertNotNil(manager)
        
        // 测试当前语言代码
        let languageCode = manager.currentLanguageCode()
        XCTAssertFalse(languageCode.isEmpty)
    }
    
    func testLocalizedStringRetrieval() {
        let manager = LocalizationManager.shared
        
        // 测试获取本地化字符串
        let invalidURLString = manager.localizedString(for: "network.error.invalid_url", defaultValue: "Invalid URL")
        XCTAssertFalse(invalidURLString.isEmpty)
        
        // 测试带参数的本地化字符串
        let serverErrorString = manager.localizedString(for: "network.error.server_error", defaultValue: "Server error, status code: %d", with: 500)
        XCTAssertFalse(serverErrorString.isEmpty)
        XCTAssertTrue(serverErrorString.contains("500"))
        
        // 测试不存在的键
        let missingKeyString = manager.localizedString(for: "missing.key", defaultValue: "Default Value")
        XCTAssertEqual(missingKeyString, "Default Value")
    }
    
    func testLanguageSwitching() {
        let manager = LocalizationManager.shared
        
        // 测试支持的语言
        let supportedLanguages = manager.supportedLanguages()
        XCTAssertFalse(supportedLanguages.isEmpty)
        
        // 测试切换语言
        let currentLanguage = manager.currentLanguageCode()
        
        // 注意：由于测试环境中可能没有完整的本地化资源，我们只测试方法是否能正常调用
        manager.switchLanguage(to: "en")
        manager.switchLanguage(to: "zh-Hans")
        
        // 切换回原语言
        manager.switchLanguage(to: currentLanguage)
    }
    
    func testLocalizationKeys() {
        // 测试所有预定义的本地化键
        let keys: [LocalizationKey] = [
            .invalidURL,
            .noData,
            .decodingError,
            .serverError,
            .httpError,
            .sslCertificateVerificationFailed,
            .unknownError,
            .weakNetwork,
            .timeout,
            .networkUnreachable,
            .weakNetworkNotAllowed,
            .parsingError,
            .requestSending,
            .requestSuccess,
            .requestFailure,
            .requestComplete
        ]
        
        let manager = LocalizationManager.shared
        
        for key in keys {
            let localizedString = manager.localizedString(for: key.rawValue)
            XCTAssertFalse(localizedString.isEmpty, "本地化键 '\(key.rawValue)' 的字符串为空")
        }
    }
}