//
//  RxSwiftSupport.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
#if canImport(RxSwift)
import RxSwift
import RxCocoa

extension NetworkManager {
    /// 使用RxSwift发送请求
    /// - Parameter request: 符合APIRequest协议的请求对象
    /// - Returns: Observable包含解析后的数据
    public func rxRequest<T: Decodable, R: APIRequest>(_ request: R) -> Observable<T> {
        return Observable.create { observer in
            let cancellable = self.request(request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    /// 使用RxSwift发送Protobuf请求
    /// - Parameter request: 符合ProtobufAPIRequest协议的请求对象
    /// - Returns: Observable包含解析后的数据
    #if canImport(SwiftProtobuf)
    public func rxRequest<P: ProtobufAPIRequest>(_ request: P) -> Observable<P.ResponseMessage> {
        return Observable.create { observer in
            let cancellable = self.request(request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    #endif
    
    /// 使用RxSwift发送请求并管理加载视图
    /// - Parameter request: 符合APIRequest协议的请求对象
    /// - Returns: Observable包含解析后的数据
    public func rxRequestWithLoading<T: Decodable, R: APIRequest>(_ request: R) -> Observable<T> {
        return Observable.create { observer in
            let cancellable = self.requestWithLoading(request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    /// 使用RxSwift发送Protobuf请求并管理加载视图
    /// - Parameter request: 符合ProtobufAPIRequest协议的请求对象
    /// - Returns: Observable包含解析后的数据
    #if canImport(SwiftProtobuf)
    public func rxRequestWithLoading<P: ProtobufAPIRequest>(_ request: P) -> Observable<P.ResponseMessage> {
        return Observable.create { observer in
            let cancellable = self.requestWithLoading(request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    #endif
    
    /// 使用RxSwift组合两个请求
    /// - Parameters:
    ///   - request1: 第一个请求
    ///   - request2: 第二个请求
    /// - Returns: Observable包含两个请求的结果
    public func rxCombinedRequest<T1: Decodable, T2: Decodable,
                                  R1: APIRequest, R2: APIRequest>(
        _ request1: R1,
        _ request2: R2
    ) -> Observable<(T1, T2)> {
        return Observable.create { observer in
            let cancellable = self.combinedRequest(request1, request2)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    /// 使用RxSwift组合三个请求
    /// - Parameters:
    ///   - request1: 第一个请求
    ///   - request2: 第二个请求
    ///   - request3: 第三个请求
    /// - Returns: Observable包含三个请求的结果
    public func rxCombinedRequest<T1: Decodable, T2: Decodable, T3: Decodable,
                                  R1: APIRequest, R2: APIRequest, R3: APIRequest>(
        _ request1: R1,
        _ request2: R2,
        _ request3: R3
    ) -> Observable<(T1, T2, T3)> {
        return Observable.create { observer in
            let cancellable = self.combinedRequest(request1, request2, request3)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    #if canImport(SwiftProtobuf)
    /// 使用RxSwift组合两个Protobuf请求
    /// - Parameters:
    ///   - request1: 第一个Protobuf请求
    ///   - request2: 第二个Protobuf请求
    /// - Returns: Observable包含两个请求的结果
    public func rxCombinedProtobufRequest<P1: ProtobufAPIRequest, P2: ProtobufAPIRequest>(
        _ request1: P1,
        _ request2: P2
    ) -> Observable<(P1.ResponseMessage, P2.ResponseMessage)> {
        return Observable.create { observer in
            let cancellable = self.combinedProtobufRequest(request1, request2)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
    /// 使用RxSwift组合三个Protobuf请求
    /// - Parameters:
    ///   - request1: 第一个Protobuf请求
    ///   - request2: 第二个Protobuf请求
    ///   - request3: 第三个Protobuf请求
    /// - Returns: Observable包含三个请求的结果
    public func rxCombinedProtobufRequest<P1: ProtobufAPIRequest, P2: ProtobufAPIRequest, P3: ProtobufAPIRequest>(
        _ request1: P1,
        _ request2: P2,
        _ request3: P3
    ) -> Observable<(P1.ResponseMessage, P2.ResponseMessage, P3.ResponseMessage)> {
        return Observable.create { observer in
            let cancellable = self.combinedProtobufRequest(request1, request2, request3)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    },
                    receiveValue: { value in
                        observer.onNext(value)
                    }
                )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    #endif
    
    /// 使用RxSwift发送原始Moya请求
    /// - Parameter target: Moya TargetType
    /// - Returns: Observable包含Moya响应
    public func rxRequest<T: TargetType>(_ target: T) -> Observable<Response> {
        return Observable.create { observer in
            let cancellable = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
    
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
    
    #if canImport(SwiftProtobuf)
    /// 创建一个定时轮询Protobuf请求的Observable
    /// - Parameters:
    ///   - request: Protobuf请求对象
    ///   - interval: 轮询间隔
    /// - Returns: Observable
    public func rxPollingProtobufRequest<P: ProtobufAPIRequest>(
        _ request: P,
        interval: RxTimeInterval
    ) -> Observable<P.ResponseMessage> {
        return Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .flatMapLatest { _ in
                return self.rxRequest(request)
            }
    }
    #endif
}

#endif