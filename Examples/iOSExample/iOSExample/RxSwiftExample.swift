//
//  RxSwiftExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
#if canImport(RxSwift)
import RxSwift
import RxCocoa
import FMNetCore

class RxSwiftExampleViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRxExamples()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "RxSwift示例"
    }
    
    private func setupRxExamples() {
        // 示例1: 基本请求
        basicRequestExample()
        
        // 示例2: 组合请求
        combinedRequestExample()
        
        // 示例3: 错误处理
        errorHandlingExample()
        
        // 示例4: 重试机制
        retryExample()
        
        // 示例5: 轮询请求
        pollingExample()
    }
    
    private func basicRequestExample() {
        let request = GetUsersRequest()
        
        NetworkManager.shared.rxRequest<[User]>(request)
            .subscribe(
                onNext: { (users: [User]) in
                    print("RxSwift - 成功获取 \(users.count) 个用户")
                },
                onError: { error in
                    print("RxSwift - 获取用户失败: \(error)")
                },
                onCompleted: {
                    print("RxSwift - 获取用户请求完成")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func combinedRequestExample() {
        let usersRequest = GetUsersRequest()
        let postsRequest = GetPostsRequest()
        
        NetworkManager.shared.rxCombinedRequest<[User], [Post], GetUsersRequest, GetPostsRequest>(usersRequest, postsRequest)
            .subscribe(
                onNext: { (users: [User], posts: [Post]) in
                    print("RxSwift - 成功获取 \(users.count) 个用户和 \(posts.count) 个帖子")
                },
                onError: { error in
                    print("RxSwift - 组合请求失败: \(error)")
                },
                onCompleted: {
                    print("RxSwift - 组合请求完成")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func errorHandlingExample() {
        let request = GetUsersRequest()
        
        NetworkManager.shared.rxRequest<[User]>(request)
            .catchAndReturn([]) // 错误时返回空数组
            .subscribe(
                onNext: { (users: [User]) in
                    print("RxSwift - 获取用户结果: \(users.count) 个用户")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func retryExample() {
        let request = GetUsersRequest()
        
        NetworkManager.shared.rxRequest<[User]>(request)
            .retry(3) // 重试3次
            .subscribe(
                onNext: { (users: [User]) in
                    print("RxSwift - 重试示例 - 成功获取 \(users.count) 个用户")
                },
                onError: { error in
                    print("RxSwift - 重试示例 - 获取用户失败: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func pollingExample() {
        let request = GetUsersRequest()
        
        // 每5秒轮询一次
        NetworkManager.shared.rxPollingRequest<[User]>(request, interval: .seconds(5))
            .subscribe(
                onNext: { (users: [User]) in
                    print("RxSwift - 轮询示例 - 获取到 \(users.count) 个用户")
                },
                onError: { error in
                    print("RxSwift - 轮询示例 - 获取用户失败: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
}

// 扩展示例：使用RxCocoa绑定到UI
extension RxSwiftExampleViewController {
    private func setupUIBindingExample() {
        // 创建UI元素
        let searchTextField = UITextField()
        let resultLabel = UILabel()
        let activityIndicator = UIActivityIndicatorView()
        
        // 设置UI
        searchTextField.placeholder = "搜索用户..."
        resultLabel.text = "请输入搜索关键词"
        
        // 使用RxCocoa绑定
        searchTextField.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .do(onNext: { _ in
                activityIndicator.startAnimating()
            })
            .flatMapLatest { (query: String?) -> Observable<[User]> in
                guard let query = query, !query.isEmpty else {
                    return Observable.just([])
                }
                let request = SearchUsersRequest(query: query)
                return NetworkManager.shared.rxRequest<[User]>(request)
                    .catchAndReturn([])
            }
            .do(onNext: { _ in
                activityIndicator.stopAnimating()
            })
            .map { (users: [User]) in
                return "找到 \(users.count) 个用户"
            }
            .bind(to: resultLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 错误处理示例
        searchTextField.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .flatMapLatest { (query: String?) -> Observable<[User]> in
                guard let query = query, !query.isEmpty else {
                    return Observable.just([])
                }
                let request = SearchUsersRequest(query: query)
                return NetworkManager.shared.rxRequest<[User]>(request)
            }
            .subscribe(
                onNext: { (users: [User]) in
                    resultLabel.text = "找到 \(users.count) 个用户"
                },
                onError: { error in
                    resultLabel.text = "搜索失败: \(error.localizedDescription)"
                }
            )
            .disposed(by: disposeBag)
    }
}

// 搜索用户请求示例
struct SearchUsersRequest: APIRequest {
    typealias Target = UserAPI
    
    let query: String
    
    init(query: String) {
        self.query = query
    }
    
    func asTarget() -> UserAPI {
        // 这里应该实现一个实际的搜索API
        return .getUsers
    }
    
    var needsLoadingIndicator: Bool { true }
    
    var retryCount: Int? { return 2 }
}

// 使用Observable的网络管理器扩展
extension NetworkManager {
    /// 创建一个定时轮询的Observable
    /// - Parameters:
    ///   - request: 请求对象
    ///   - interval: 轮询间隔
    /// - Returns: Observable
    public func rxPollingRequest<T: Decodable, R: APIRequest>(
        _ request: R,
        interval: RxTimeInterval
    ) -> Observable<T> {
        return Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .flatMapLatest { _ in
                return self.rxRequest<T>(request)
            }
    }
}

#endif