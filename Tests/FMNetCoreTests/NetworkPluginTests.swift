//
//  NetworkPluginTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/12.
//

import XCTest
import Moya
@testable import FMNetCore

class MockNetworkPlugin: NetworkPlugin {
    var prepareCalled = false
    var processCalled = false
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        prepareCalled = true
        return request
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        processCalled = true
        return result
    }
}

class NetworkPluginTests: XCTestCase {
    
    func testPluginPrepare() {
        let plugin = MockNetworkPlugin()
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let modifiedRequest = plugin.prepare(request, target: ExampleAPI.getUsers)
        
        XCTAssertTrue(plugin.prepareCalled)
        XCTAssertEqual(modifiedRequest.url, url)
        XCTAssertEqual(modifiedRequest.httpMethod, "GET")
    }
    
    func testPluginProcess() {
        let plugin = MockNetworkPlugin()
        let url = URL(string: "https://example.com")!
        let response = Moya.Response(statusCode: 200, data: Data(), request: nil, response: nil)
        let result: Result<Moya.Response, MoyaError> = .success(response)
        
        let processedResult = plugin.process(result, target: ExampleAPI.getUsers)
        
        XCTAssertTrue(plugin.processCalled)
        switch processedResult {
        case .success(let processedResponse):
            XCTAssertEqual(processedResponse.statusCode, 200)
        case .failure:
            XCTFail("Expected success result")
        }
    }
}