//
//  CacheStatsViewController.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import UIKit

class CacheStatsViewController: UIViewController {
    
    private var tableView: UITableView!
    private var stats: CacheStats!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStats()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "缓存统计"
        
        // 创建表格视图
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CacheStatCell")
        view.addSubview(tableView)
    }
    
    private func loadStats() {
        stats = CacheManager.shared.getCacheStats()
        tableView.reloadData()
    }
    
    @objc private func refreshStats() {
        loadStats()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CacheStatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // 统计项数量
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CacheStatCell", for: indexPath)
        
        let stat = cacheStats[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = stat.name
            content.secondaryText = stat.value
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = stat.name
            cell.detailTextLabel?.text = stat.value
        }
        
        return cell
    }
}

private var cacheStats: [CacheStat] {
    let manager = CacheManager.shared
    return [
        CacheStat(name: "内存命中次数", value: "\(manager.getCacheStats().memoryHitCount)"),
        CacheStat(name: "磁盘命中次数", value: "\(manager.getCacheStats().diskHitCount)"),
        CacheStat(name: "未命中次数", value: "\(manager.getCacheStats().missCount)"),
        CacheStat(name: "命中率", value: String(format: "%.2f%%", manager.getCacheStats().hitRate * 100)),
        CacheStat(name: "内存缓存数量", value: "\(manager.getCacheStats().memoryCacheCount)"),
        CacheStat(name: "磁盘缓存数量", value: "\(manager.getCacheStats().diskCacheCount)")
    ]
}

struct CacheStat {
    let name: String
    let value: String
}
