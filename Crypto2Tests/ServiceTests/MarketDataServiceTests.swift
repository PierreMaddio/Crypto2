//
//  MarketDataServiceTests.swift
//  Crypto2Tests
//
//  Created by Pierre on 29/09/2022.
//

import XCTest
@testable import Crypto2

final class MarketDataServiceTests: XCTestCase {
    // custom urlsession for mock network calls
    var urlSession: URLSession!

    override func setUpWithError() throws {
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }
    
    func testGetData() async throws {
        // CoinDataService. Injected with custom url session for mocking
        let marketDataService = MarketDataService(urlSession: urlSession)
        
        // Set mock data
        
        let sampleMarketData = MarketData(
            totalMarketCap: [
                "btc": 50688291.70782815,
                "eth": 741914096.1553786
            ],
            totalVolume: [
                "btc": 3926938.192657288,
                "eth": 57477786.32305778
            ],
            marketCapPercentage: [
                "btc": 37.80727853087002,
                "eth": 16.271085959650602
            ],
            marketCapChangePercentage24HUsd: -0.6016048565865182)
        
        let mockData = try JSONEncoder().encode(sampleMarketData)
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")

        let market = try await marketDataService.getData()
        XCTAssertEqual(market.data?.marketCapChangePercentage24HUsd, nil)
        expectation.fulfill()
        wait(for: [expectation], timeout: 1)
    }

}
