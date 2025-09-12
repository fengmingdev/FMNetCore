//
//  CacheManagerTests.swift
//  NetworkingTests
//
//  Created by fengming on 2025/9/12.
//

import XCTest
@testable import Networking

final class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    
    override func setUpWithError() throws {
        cacheManager = CacheManager.shared
    }
    
    override func tearDownWithError() throws {
        cacheManager.clearAllCache()
        cacheManager = nil
    }
    
    func testCacheManagerSingleton() throws {
        let manager1 = CacheManager.shared
        let manager2 = CacheManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func testMemoryCacheSetAndGet() throws {
        let key = "test_key"
        let value = "test_value" as AnyObject
        
        // 设置缓存
        cacheManager.setMemoryCache(value, forKey: key)
        
        // 获取缓存
        let cachedValue = cacheManager.getMemoryCache(forKey: key)
        XCTAssertEqual(cachedValue as? String, value as? String)
    }
    
    func testMemoryCacheExpiry() throws {
        let key = "test_key_expiry"
        let value = "test_value" as AnyObject
        
        // 设置缓存，过期时间为1秒
        cacheManager.setMemoryCache(value, forKey: key, expiry: 1)
        
        // 立即获取应该能获取到
        var cachedValue = cacheManager.getMemoryCache(forKey: key)
        XCTAssertEqual(cachedValue as? String, value as? String)
        
        // 等待1秒后应该获取不到
        let expectation = self.expectation(description: "Wait for cache expiry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            cachedValue = self.cacheManager.getMemoryCache(forKey: key)
            XCTAssertNil(cachedValue)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDiskCacheSetAndGet() throws {
        let key = "test_disk_key"
        let data = "test_data".data(using: .utf8)!
        
        // 设置磁盘缓存
        cacheManager.setDiskCache(data, forKey: key)
        
        // 获取磁盘缓存
        let cachedData = cacheManager.getDiskCache(forKey: key)
        XCTAssertEqual(cachedData, data)
    }
    
    func testDiskCacheExpiry() throws {
        let key = "test_disk_key_expiry"
        let data = "test_data".data(using: .utf8)!
        
        // 设置磁盘缓存，过期时间为1秒
        cacheManager.setDiskCache(data, forKey: key, expiry: 1)
        
        // 立即获取应该能获取到
        var cachedData = cacheManager.getDiskCache(forKey: key)
        XCTAssertEqual(cachedData, data)
        
        // 等待1秒后应该获取不到
        let expectation = self.expectation(description: "Wait for disk cache expiry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            cachedData = self.cacheManager.getDiskCache(forKey: key)
            XCTAssertNil(cachedData)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testClearMemoryCache() throws {
        let key = "test_clear_key"
        let value = "test_value" as AnyObject
        
        // 设置缓存
        cacheManager.setMemoryCache(value, forKey: key)
        
        // 清除内存缓存
        cacheManager.clearMemoryCache()
        
        // 应该获取不到缓存
        let cachedValue = cacheManager.getMemoryCache(forKey: key)
        XCTAssertNil(cachedValue)
    }
    
    func testClearDiskCache() throws {
        let key = "test_clear_disk_key"
        let data = "test_data".data(using: .utf8)!
        
        // 设置磁盘缓存
        cacheManager.setDiskCache(data, forKey: key)
        
        // 清除磁盘缓存
        cacheManager.clearDiskCache()
        
        // 应该获取不到缓存
        let cachedData = cacheManager.getDiskCache(forKey: key)
        XCTAssertNil(cachedData)
    }
    
    func testClearAllCache() throws {
        let memoryKey = "test_memory_key"
        let diskKey = "test_disk_key"
        let memoryValue = "test_memory_value" as AnyObject
        let diskData = "test_disk_data".data(using: .utf8)!
        
        // 设置内存和磁盘缓存
        cacheManager.setMemoryCache(memoryValue, forKey: memoryKey)
        cacheManager.setDiskCache(diskData, forKey: diskKey)
        
        // 清除所有缓存
        cacheManager.clearAllCache()
        
        // 应该都获取不到缓存
        let cachedMemoryValue = cacheManager.getMemoryCache(forKey: memoryKey)
        let cachedDiskData = cacheManager.getDiskCache(forKey: diskKey)
        
        XCTAssertNil(cachedMemoryValue)
        XCTAssertNil(cachedDiskData)
    }
    
    func testCacheConfigDefaultValues() throws {
        let config = CacheConfig()
        XCTAssertEqual(config.maxDiskCacheSize, 50 * 1024 * 1024) // 50MB
        XCTAssertEqual(config.defaultMemoryExpiry, 300) // 5分钟
        XCTAssertEqual(config.defaultDiskExpiry, 3600) // 1小时
    }
    
    func testCacheConfigCustomValues() throws {
        var config = CacheConfig()
        config.maxDiskCacheSize = 100 * 1024 * 1024 // 100MB
        config.defaultMemoryExpiry = 600 // 10分钟
        config.defaultDiskExpiry = 7200 // 2小时
        
        XCTAssertEqual(config.maxDiskCacheSize, 100 * 1024 * 1024)
        XCTAssertEqual(config.defaultMemoryExpiry, 600)
        XCTAssertEqual(config.defaultDiskExpiry, 7200)
    }
}