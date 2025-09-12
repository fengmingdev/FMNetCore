//
//  Combine+Extensions.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine

extension NetworkStatus: Equatable {
    static func == (lhs: NetworkStatus, rhs: NetworkStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unreachable, .unreachable):
            return true
        case (.wifi, .wifi):
            return true
        case (.cellular(let quality1), .cellular(let quality2)):
            return quality1 == quality2
        default:
            return false
        }
    }
}

extension NetworkQuality: Equatable {
    static func == (lhs: NetworkQuality, rhs: NetworkQuality) -> Bool {
        switch (lhs, rhs) {
        case (.excellent, .excellent):
            return true
        case (.good, .good):
            return true
        case (.fair, .fair):
            return true
        case (.poor, .poor):
            return true
        default:
            return false
        }
    }
}