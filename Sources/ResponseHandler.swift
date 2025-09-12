//
//  ResponseHandler.swift
//  Networking
//
//  Created by fengming on 2025/9/12.
//

import Foundation
import Combine
import Moya

/// 响应处理器
final class ResponseHandler {
    static let shared = ResponseHandler()
    private init() {}
    
    /// 异步处理响应
    /// - Parameter response: Moya响应
    /// - Returns: 解析后的数据
    func handleResponse<T: Decodable>(_ response: Response) -> AnyPublisher<T, NetworkError> {
        // 检查状态码
        guard 200..<300 ~= response.statusCode else {
            return Fail(error: NetworkError.httpError(code: response.statusCode)).eraseToAnyPublisher()
        }
        
        // 解析数据
        return Just(response.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(error: decodingError)
                } else {
                    return NetworkError.parsingError
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// 同步处理响应
    /// - Parameter response: Moya响应
    /// - Returns: 解析后的数据
    func handleResponseSync<T: Decodable>(_ response: Response) throws -> T {
        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.httpError(code: response.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: response.data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(error: decodingError)
        } catch {
            throw NetworkError.parsingError
        }
    }
}