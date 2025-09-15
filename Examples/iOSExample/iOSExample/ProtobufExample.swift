//
//  ProtobufExample.swift
//  iOSExample
//
//  Created by Fengming on 2025/9/15.
//

import Foundation
#if canImport(SwiftProtobuf)
import SwiftProtobuf
import FMNetCore
import Combine

// 示例Protobuf消息（实际使用时需要通过.proto文件生成）
/*
syntax = "proto3";

message UserRequest {
  int32 user_id = 1;
}

message UserResponse {
  int32 id = 1;
  string name = 2;
  string email = 3;
}
*/

// 由于我们没有实际的.proto文件，这里创建模拟的消息结构
// 在实际项目中，这些应该由protoc-gen-swift生成
public struct MockUserRequest: Message {
    public var id: Int32 = 0
    public var name: String = ""
    public var email: String = ""
    
    public init() {}
    
    // 实现Message协议需要的方法（简化版）
    public var isInitialized: Bool { true }
    public var debugDescription: String { "MockUserRequest(id: \(id), name: \(name), email: \(email))" }
    
    // 这些方法在实际的Protobuf生成代码中会自动生成
    public func serializedData() throws -> Data { 
        // 简化实现，实际应该使用Protobuf序列化
        return Data()
    }
    
    public init(serializedData: Data) throws { 
        self.init()
        // 简化实现，实际应该解析数据
    }
    
    public init(jsonUTF8Data: Data) throws { 
        self.init()
        // 简化实现，实际应该解析JSON
    }
    
    public func jsonUTF8Data() throws -> Data { 
        // 简化实现，实际应该序列化为JSON
        return Data()
    }
    
    // 必需的Message协议方法
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        // 简化实现
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularInt32Field(value: &id)
            case 2: try decoder.decodeSingularStringField(value: &name)
            case 3: try decoder.decodeSingularStringField(value: &email)
            default: break
            }
        }
    }
    
    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if id != 0 {
            try visitor.visitSingularInt32Field(value: id, fieldNumber: 1)
        }
        if !name.isEmpty {
            try visitor.visitSingularStringField(value: name, fieldNumber: 2)
        }
        if !email.isEmpty {
            try visitor.visitSingularStringField(value: email, fieldNumber: 3)
        }
    }
    
    public static var protoMessageName: String { "MockUserRequest" }
    public static var _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "id"),
        2: .same(proto: "name"),
        3: .same(proto: "email")
    ]
    
    // 添加缺失的协议要求
    public typealias UnknownFields = SwiftProtobuf.UnknownStorage
    public var unknownFields = UnknownFields()
    
    // 添加协议要求的 isEqualTo 方法
    public func isEqualTo(message: any Message) -> Bool {
        guard let other = message as? MockUserRequest else { return false }
        return self.id == other.id && self.name == other.name && self.email == other.email
    }
}

public struct MockUserResponse: Message {
    public var id: Int32 = 0
    public var name: String = ""
    public var email: String = ""
    
    public init() {}
    
    // 实现Message协议需要的方法（简化版）
    public var isInitialized: Bool { true }
    public var debugDescription: String { "MockUserResponse(id: \(id), name: \(name), email: \(email))" }
    
    // 这些方法在实际的Protobuf生成代码中会自动生成
    public func serializedData() throws -> Data { 
        // 简化实现，实际应该使用Protobuf序列化
        return Data()
    }
    
    public init(serializedData: Data) throws { 
        self.init()
        // 简化实现，实际应该解析数据
    }
    
    public init(jsonUTF8Data: Data) throws { 
        self.init()
        // 简化实现，实际应该解析JSON
    }
    
    public func jsonUTF8Data() throws -> Data { 
        // 简化实现，实际应该序列化为JSON
        return Data()
    }
    
    // 必需的Message协议方法
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        // 简化实现
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularInt32Field(value: &id)
            case 2: try decoder.decodeSingularStringField(value: &name)
            case 3: try decoder.decodeSingularStringField(value: &email)
            default: break
            }
        }
    }
    
    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if id != 0 {
            try visitor.visitSingularInt32Field(value: id, fieldNumber: 1)
        }
        if !name.isEmpty {
            try visitor.visitSingularStringField(value: name, fieldNumber: 2)
        }
        if !email.isEmpty {
            try visitor.visitSingularStringField(value: email, fieldNumber: 3)
        }
    }
    
    public static var protoMessageName: String { "MockUserResponse" }
    public static var _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "id"),
        2: .same(proto: "name"),
        3: .same(proto: "email")
    ]
    
    // 添加缺失的协议要求
    public typealias UnknownFields = SwiftProtobuf.UnknownStorage
    public var unknownFields = UnknownFields()
    
    // 添加协议要求的 isEqualTo 方法
    public func isEqualTo(message: any Message) -> Bool {
        guard let other = message as? MockUserResponse else { return false }
        return self.id == other.id && self.name == other.name && self.email == other.email
    }
}

// Protobuf API请求示例
struct GetUserProtobufRequest: ProtobufAPIRequest {
    typealias Target = UserAPI
    typealias RequestMessage = MockUserRequest
    typealias ResponseMessage = MockUserResponse
    
    let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func asTarget() -> UserAPI {
        return .getUser(id: userId)
    }
    
    func buildRequestMessage() -> MockUserRequest? {
        var request = MockUserRequest()
        request.id = Int32(userId)
        // 在实际应用中，这里会设置请求参数
        return request
    }
    
    func parseResponseMessage(from data: Data) throws -> MockUserResponse {
        return try MockUserResponse(serializedData: data)
    }
    
    // 自定义重试次数
    var retryCount: Int? { return 2 }
    
    // 需要显示加载指示器
    var needsLoadingIndicator: Bool { true }
}

// Protobuf网络请求使用示例
class ProtobufExampleViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExamples()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Protobuf示例"
    }
    
    private func setupExamples() {
        // 示例1: 基本Protobuf请求
        basicProtobufRequestExample()
        
        // 示例2: 组合Protobuf请求
        combinedProtobufRequestExample()
    }
    
    private func basicProtobufRequestExample() {
        let request = GetUserProtobufRequest(userId: 1)
        
        // 使用Combine
        NetworkManager.shared.request(request)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Protobuf请求完成")
                    case .failure(let error):
                        print("Protobuf请求失败: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Protobuf请求成功: \(response)")
                }
            )
            .store(in: &cancellables)
            
        // 使用RxSwift
        #if canImport(RxSwift)
        NetworkManager.shared.rxRequest(request)
            .subscribe(
                onNext: { response in
                    print("RxSwift Protobuf请求成功: \(response)")
                },
                onError: { error in
                    print("RxSwift Protobuf请求失败: \(error)")
                },
                onCompleted: {
                    print("RxSwift Protobuf请求完成")
                }
            )
            .disposed(by: DisposeBag())
        #endif
    }
    
    private func combinedProtobufRequestExample() {
        let request1 = GetUserProtobufRequest(userId: 1)
        let request2 = GetUserProtobufRequest(userId: 2)
        
        // 使用Combine组合请求
        NetworkManager.shared.combinedProtobufRequest(request1, request2)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("组合Protobuf请求完成")
                    case .failure(let error):
                        print("组合Protobuf请求失败: \(error)")
                    }
                },
                receiveValue: { (response1, response2) in
                    print("组合Protobuf请求成功: \(response1), \(response2)")
                }
            )
            .store(in: &cancellables)
            
        // 使用RxSwift组合请求
        #if canImport(RxSwift)
        NetworkManager.shared.rxCombinedProtobufRequest(request1, request2)
            .subscribe(
                onNext: { (response1, response2) in
                    print("RxSwift组合Protobuf请求成功: \(response1), \(response2)")
                },
                onError: { error in
                    print("RxSwift组合Protobuf请求失败: \(error)")
                },
                onCompleted: {
                    print("RxSwift组合Protobuf请求完成")
                }
            )
            .disposed(by: DisposeBag())
        #endif
    }
}

#endif
