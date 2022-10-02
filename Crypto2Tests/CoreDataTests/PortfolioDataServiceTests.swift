//
//  PortfolioDataServiceTests.swift
//  Crypto2Tests
//
//  Created by Pierre on 01/10/2022.
//

import XCTest
@testable import Crypto2

final class PortfolioDataServiceTests: XCTestCase {
    var service: PortfolioDataServiceProtocol!
    var sampleCoin: Coin!
    
    override func setUpWithError()  throws {
        service = MockPortfolioDataService()
        
        sampleCoin = Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579", currentPrice: 19488.51, marketCap: 373484860831, marketCapRank: 1.0, fullyDilutedValuation: 409270584218.0, totalVolume: 37170695130.0, high24H: 19704.08, low24H: 18971.94, priceChange24H: 500.44, priceChangePercentage24H: 2.63554, marketCapChange24H: 10118810515.0, marketCapChangePercentage24H: 2.78474, circulatingSupply: 19163806.0, totalSupply: 21000000.0, maxSupply: 21000000.0, ath: 69045.0, athChangePercentage: -71.76019, athDate: "2021-11-10T14:24:11.849Z", atl: 67.81, atlChangePercentage: 28654.4632, atlDate: "2013-07-06T00:00:00.000Z", lastUpdated: "2022-09-29T12:07:57.143Z", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 2.6355372761273657, currentHoldings: 3.0)
    }
    
    func testUpdatePortfolio() async throws {
        
    }
    
    //    func testExample() async throws {
    //            var updatedNum: Int? = nil
    //
    //            //Create the stream
    //            let stream = testModel.listener()
    //
    //            let newNum = Int.random(in: 0...200)
    //            //Make a change
    //            testModel.update(num: newNum)
    //
    //            updatedNum = try await Task{
    //                for try await num in stream{
    //                    //return when you have a value
    //                    return num
    //                }
    //                //If the stream is ended prematurely
    //                return -1
    //            }.value
    //            //Check that the updated value is correct
    //            XCTAssertEqual(newNum, updatedNum)
    //        }
    
    
    
}
