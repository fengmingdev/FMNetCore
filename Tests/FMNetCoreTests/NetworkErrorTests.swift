//
//  NetworkErrorTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/12.
//

import XCTest
@testable import FMNetCore

class NetworkErrorTests: XCTestCase {
    
    func testInvalidURLError() {
        let error = NetworkError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }
    
    func testNoDataError() {
        let error = NetworkError.noData
        XCTAssertEqual(error.errorDescription, "No data received")
    }
    
    func testDecodingError() {
        let error = NetworkError.decodingError
        XCTAssertEqual(error.errorDescription, "Failed to decode data")
    }
    
    func testServerError() {
        let error = NetworkError.serverError(500)
        XCTAssertEqual(error.errorDescription, "Server error with status code: 500")
    }
    
    func testUnknownError() {
        let error = NetworkError.unknown
        XCTAssertEqual(error.errorDescription, "Unknown error occurred")
    }
}