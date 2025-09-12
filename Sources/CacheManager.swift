//
//  CacheManager.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation

/// 缓存管理器
/// 负责管理网络请求的缓存，提高性能和用户体验
public final class CacheManager {
    /// 单例实例
    public static let shared = CacheManager()
    
    /// 内存缓存
    private let memoryCache = NSCache<NSString, AnyObject>()
    
    /// 磁盘缓存路径
    private let diskCachePath: String
    
    /// 磁盘缓存队列
    private let diskQueue = DispatchQueue(label: "com.networking.cache.disk", qos: .background)
    
    /// 缓存配置
    private let config: CacheConfig
    
    /// 缓存统计信息
    private var cacheStats = CacheStats()
    
    /// 私有初始化方法
    private init(config: CacheConfig = CacheConfig()) {
        self.config = config
        
        // 设置磁盘缓存路径
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        self.diskCachePath = (cachePath as NSString).appendingPathComponent("NetworkingCache")
        
        // 创建磁盘缓存目录
        try? FileManager.default.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
        
        // 启动定时清理
        setupPeriodicCleanup()
    }
    
    /// 设置定期清理缓存
    private func setupPeriodicCleanup() {
        // 每小时检查一次缓存大小
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.cleanupIfNeeded()
        }
    }
    
    /// 根据需要清理缓存
    private func cleanupIfNeeded() {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            
            let cacheSize = self.getDiskCacheSize()
            if cacheSize > self.config.maxDiskCacheSize {
                self.cleanDiskCache()
            }
        }
    }
    
    /// 获取磁盘缓存大小
    /// - Returns: 缓存大小（字节）
    private func getDiskCacheSize() -> UInt64 {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: diskCachePath) else {
            return 0
        }
        
        var size: UInt64 = 0
        for content in contents {
            let filePath = (diskCachePath as NSString).appendingPathComponent(content)
            if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
               let fileSize = attributes[.size] as? UInt64 {
                size += fileSize
            }
        }
        
        return size
    }
    
    /// 获取磁盘缓存条目数量
    /// - Returns: 缓存条目数量
    private func getDiskCacheCount() -> Int {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: diskCachePath) else {
            return 0
        }
        
        return contents.count
    }
    
    /// 清理磁盘缓存
    private func cleanDiskCache() {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: diskCachePath) else {
            return
        }
        
        // 按修改时间排序，删除最旧的文件
        let fileURLs = contents.map { (diskCachePath as NSString).appendingPathComponent($0) }
            .compactMap { URL(fileURLWithPath: $0) }
        
        let sortedFiles = fileURLs.sorted { url1, url2 in
            guard let attr1 = try? FileManager.default.attributesOfItem(atPath: url1.path),
                  let attr2 = try? FileManager.default.attributesOfItem(atPath: url2.path),
                  let date1 = attr1[.modificationDate] as? Date,
                  let date2 = attr2[.modificationDate] as? Date else {
                return false
            }
            return date1 < date2
        }
        
        // 删除一半的文件
        let filesToDelete = sortedFiles.prefix(sortedFiles.count / 2)
        for fileURL in filesToDelete {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    /// 生成缓存键
    /// - Parameter key: 原始键
    /// - Returns: MD5哈希后的键
    private func generateCacheKey(_ key: String) -> String {
        // 简单的MD5实现（实际项目中可以使用更安全的哈希算法）
        return key.data(using: .utf8)?.base64EncodedString() ?? key
    }
    
    /// 存储数据到内存缓存
    /// - Parameters:
    ///   - data: 要缓存的数据
    ///   - key: 缓存键
    ///   - expiry: 过期时间（秒）
    ///   - cacheType: 缓存类型
    public func setMemoryCache(_ data: AnyObject, forKey key: String, expiry: TimeInterval = 300, cacheType: CacheType = .memory) {
        let cacheKey = generateCacheKey(key) as NSString
        memoryCache.setObject(data, forKey: cacheKey, cost: 1)
        
        // 更新统计信息
        cacheStats.updateMemoryCacheCount(memoryCache.countLimit)
        
        // 设置过期时间
        DispatchQueue.global().asyncAfter(deadline: .now() + expiry) { [weak self] in
            self?.memoryCache.removeObject(forKey: cacheKey)
        }
    }
    
    /// 从内存缓存获取数据
    /// - Parameter key: 缓存键
    /// - Returns: 缓存的数据，如果不存在或已过期则返回nil
    public func getMemoryCache(forKey key: String) -> AnyObject? {
        let cacheKey = generateCacheKey(key) as NSString
        let object = memoryCache.object(forKey: cacheKey)
        
        // 更新统计信息
        if object != nil {
            cacheStats.recordMemoryHit()
        } else {
            cacheStats.recordMiss()
        }
        
        return object
    }
    
    /// 存储数据到磁盘缓存
    /// - Parameters:
    ///   - data: 要缓存的数据
    ///   - key: 缓存键
    ///   - expiry: 过期时间（秒）
    ///   - cacheType: 缓存类型
    public func setDiskCache(_ data: Data, forKey key: String, expiry: TimeInterval = 3600, cacheType: CacheType = .disk) {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            
            let cacheKey = self.generateCacheKey(key)
            let filePath = (self.diskCachePath as NSString).appendingPathComponent(cacheKey)
            
            // 创建包含过期时间的数据结构
            let cacheData = CacheData(data: data, expiryDate: Date().addingTimeInterval(expiry), key: key, cacheType: cacheType)
            var encodedData: Data?
            
            if self.config.compressDiskCache {
                // 压缩数据
                encodedData = (try? NSKeyedArchiver.archivedData(withRootObject: cacheData, requiringSecureCoding: false))
            } else {
                encodedData = try? JSONEncoder().encode(cacheData)
            }
            
            if let encodedData = encodedData {
                try? encodedData.write(to: URL(fileURLWithPath: filePath))
                
                // 更新统计信息
                self.diskQueue.async {
                    self.cacheStats.updateDiskCacheCount(self.getDiskCacheCount())
                }
            }
        }
    }
    
    /// 从磁盘缓存获取数据
    /// - Parameter key: 缓存键
    /// - Returns: 缓存的数据，如果不存在或已过期则返回nil
    public func getDiskCache(forKey key: String) -> Data? {
        let cacheKey = generateCacheKey(key)
        let filePath = (diskCachePath as NSString).appendingPathComponent(cacheKey)
        
        var cacheData: CacheData?
        
        if config.compressDiskCache {
            // 解压缩数据
            if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
               let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CacheData.self, from: data) {
                cacheData = unarchivedData
            }
        } else {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
               let decodedData = try? JSONDecoder().decode(CacheData.self, from: data) {
                cacheData = decodedData
            }
        }
        
        guard let cacheData = cacheData else {
            cacheStats.recordMiss()
            return nil
        }
        
        // 检查是否过期
        if cacheData.expiryDate < Date() {
            try? FileManager.default.removeItem(atPath: filePath)
            cacheStats.recordMiss()
            return nil
        }
        
        cacheStats.recordDiskHit()
        return cacheData.data
    }
    
    /// 清除所有缓存
    public func clearAllCache() {
        // 清除内存缓存
        memoryCache.removeAllObjects()
        
        // 清除磁盘缓存
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            try? FileManager.default.removeItem(atPath: self.diskCachePath)
            try? FileManager.default.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 重置统计信息
        cacheStats = CacheStats()
    }
    
    /// 清除内存缓存
    public func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    /// 清除磁盘缓存
    public func clearDiskCache() {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            try? FileManager.default.removeItem(atPath: self.diskCachePath)
            try? FileManager.default.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// 获取缓存统计信息
    public func getCacheStats() -> CacheStats {
        return cacheStats
    }
}

/// 缓存类型枚举
public enum CacheType: String, Codable {
    case memory
    case disk
    case both
}

/// 缓存策略枚举
public enum CachePolicy {
    case ignoreCache // 忽略缓存，直接请求网络
    case cacheOnly // 只使用缓存，不请求网络
    case cacheFirst // 优先使用缓存，如果缓存不存在则请求网络
    case networkFirst // 优先请求网络，如果网络失败则使用缓存
    case reloadIgnoringCache // 重新加载，忽略缓存
}

/// 缓存配置
public struct CacheConfig {
    /// 最大磁盘缓存大小（字节），默认50MB
    public var maxDiskCacheSize: UInt64 = 50 * 1024 * 1024
    
    /// 默认内存缓存过期时间（秒），默认5分钟
    public var defaultMemoryExpiry: TimeInterval = 300
    
    /// 默认磁盘缓存过期时间（秒），默认1小时
    public var defaultDiskExpiry: TimeInterval = 3600
    
    /// 是否启用LRU缓存淘汰策略
    public var enableLRU: Bool = true
    
    /// 内存缓存最大数量
    public var maxMemoryCacheCount: Int = 100
    
    /// 是否压缩磁盘缓存
    public var compressDiskCache: Bool = false
    
    public init() {}
}

/// 缓存统计信息
public struct CacheStats {
    public var memoryHitCount: Int = 0
    public var diskHitCount: Int = 0
    public var missCount: Int = 0
    public var memoryCacheCount: Int = 0
    public var diskCacheCount: Int = 0
    
    public mutating func recordMemoryHit() {
        memoryHitCount += 1
    }
    
    public mutating func recordDiskHit() {
        diskHitCount += 1
    }
    
    public mutating func recordMiss() {
        missCount += 1
    }
    
    public mutating func updateMemoryCacheCount(_ count: Int) {
        memoryCacheCount = count
    }
    
    public mutating func updateDiskCacheCount(_ count: Int) {
        diskCacheCount = count
    }
    
    public var hitRate: Double {
        let totalHits = memoryHitCount + diskHitCount
        let totalRequests = totalHits + missCount
        return totalRequests > 0 ? Double(totalHits) / Double(totalRequests) : 0
    }
    
    public init() {}
}

/// 缓存数据结构
public class CacheData: NSObject, NSCoding, Codable {
    /// 实际数据
    public let data: Data
    
    /// 过期日期
    public let expiryDate: Date
    
    /// 缓存创建时间
    public let createdAt: Date
    
    /// 缓存键
    public let key: String
    
    /// 缓存类型
    public let cacheType: CacheType
    
    public init(data: Data, expiryDate: Date, key: String, cacheType: CacheType = .memory) {
        self.data = data
        self.expiryDate = expiryDate
        self.createdAt = Date()
        self.key = key
        self.cacheType = cacheType
        super.init()
    }
    
    // MARK: - NSCoding
    
    public required init?(coder: NSCoder) {
        guard let data = coder.decodeObject(forKey: "data") as? Data,
              let expiryDate = coder.decodeObject(forKey: "expiryDate") as? Date,
              let createdAt = coder.decodeObject(forKey: "createdAt") as? Date,
              let key = coder.decodeObject(forKey: "key") as? String,
              let cacheTypeRawValue = coder.decodeObject(forKey: "cacheType") as? String,
              let cacheType = CacheType(rawValue: cacheTypeRawValue) else {
            return nil
        }
        
        self.data = data
        self.expiryDate = expiryDate
        self.createdAt = createdAt
        self.key = key
        self.cacheType = cacheType
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(data, forKey: "data")
        coder.encode(expiryDate, forKey: "expiryDate")
        coder.encode(createdAt, forKey: "createdAt")
        coder.encode(key, forKey: "key")
        coder.encode(cacheType.rawValue, forKey: "cacheType")
    }
}
