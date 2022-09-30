//
//  CoinDetailDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 29/09/2022.
//

import XCTest
@testable import Crypto2

final class CoinDetailDataServiceTests: XCTestCase {
    // custom urlsession for mock network calls
    var urlSession: URLSession!
    var coin: Coin!
    var sampleCoinDetailData: CoinDetail!

    override func setUpWithError() throws {
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        
        coin = Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579", currentPrice: 19488.51, marketCap: 373484860831, marketCapRank: 1.0, fullyDilutedValuation: 409270584218.0, totalVolume: 37170695130.0, high24H: 19704.08, low24H: 18971.94, priceChange24H: 500.44, priceChangePercentage24H: 2.63554, marketCapChange24H: 10118810515.0, marketCapChangePercentage24H: 2.78474, circulatingSupply: 19163806.0, totalSupply: 21000000.0, maxSupply: 21000000.0, ath: 69045.0, athChangePercentage: -71.76019, athDate: "2021-11-10T14:24:11.849Z", atl: 67.81, atlChangePercentage: 28654.4632, atlDate: "2013-07-06T00:00:00.000Z", lastUpdated: "2022-09-29T12:07:57.143Z", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 2.6355372761273657, currentHoldings: 3.0)
        
        sampleCoinDetailData = CoinDetail(id: "bitcoin", symbol: "btc", name: "Bitcoin", blockTimeInMinutes: 10, hashingAlgorithm: "SHA-256", description: nil, links: nil)
    }
    
    func testGetCoinDetails() async throws {
        // CoinDataService. Injected with custom url session for mocking
        let coinDetailDataService = CoinDetailDataService(coin: coin, urlSession: urlSession)
        
        // Set mock data
        let mockData = try JSONEncoder().encode(sampleCoinDetailData)
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        let coinDetail = try await coinDetailDataService.getCoinDetails()
        XCTAssertEqual(coinDetail.id, "bitcoin")
    }
    
    func testBadUrlString() async throws {
        // CoinDataService. Injected with custom url session for mocking
        let coinDetailDataService = CoinDetailDataService(coin: coin, urlSession: urlSession)
        
        // set blank urlString
        coinDetailDataService.urlString = ""
        
        // Set mock data
        let mockData = try JSONEncoder().encode(sampleCoinDetailData)
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }

        do {
            _ = try await coinDetailDataService.getCoinDetails()
            XCTFail("error was not thrown")
        } catch { }
    }
    
    func testBadResponseStatusCode() async throws {
        // CoinDataService. Injected with custom url session for mocking
        let coinDetailDataService = CoinDetailDataService(coin: coin, urlSession: urlSession)
        
        // Set mock data
        let mockData = try JSONEncoder().encode(sampleCoinDetailData)
        
        // Set urlResponse statusCode 500
        let response = HTTPURLResponse(url: URL(string: coinDetailDataService.urlString)!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            (response, mockData)
        }

        do {
            _ = try await coinDetailDataService.getCoinDetails()
            XCTFail("error was not thrown")
        } catch { }
    }
}
