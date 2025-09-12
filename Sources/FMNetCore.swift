//
//  FMNetCore.swift
//  FMNetCore
//
//  Created by Fengming on 2025/9/12.
//

import Foundation

/// FMNetCore 是一个功能强大的网络库，提供了简洁的 API 和丰富的功能
public struct FMNetCore {
    public private(set) var text = "Hello, FMNetCore!"
    
    public init() {
    }
}

// 公开所有重要的类型，方便外部使用
@_exported import Moya
@_exported import Alamofire