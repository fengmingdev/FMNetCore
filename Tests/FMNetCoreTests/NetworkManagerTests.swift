//
//  NetworkManagerTests.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/12.
//

import XCTest
import Moya
@testable import FMNetCore

class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testNetworkManagerInitialization() {
        XCTAssertNotNil(networkManager)
    }
    
    func testRequest() {
        let expectation = self.expectation(description: "Network request")
        
        networkManager.request(ExampleAPI.getUsers) { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Request failed with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}