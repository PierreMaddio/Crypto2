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
    var sampleCoin1: Coin!
    var sampleCoin2: Coin!
    
    override func setUpWithError()  throws {
        service = MockPortfolioDataService()
        //service = PortfolioDataService(inMemory: true)
        
        sampleCoin1 = Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579", currentPrice: 19488.51, marketCap: 373484860831, marketCapRank: 1.0, fullyDilutedValuation: 409270584218.0, totalVolume: 37170695130.0, high24H: 19704.08, low24H: 18971.94, priceChange24H: 500.44, priceChangePercentage24H: 2.63554, marketCapChange24H: 10118810515.0, marketCapChangePercentage24H: 2.78474, circulatingSupply: 19163806.0, totalSupply: 21000000.0, maxSupply: 21000000.0, ath: 69045.0, athChangePercentage: -71.76019, athDate: "2021-11-10T14:24:11.849Z", atl: 67.81, atlChangePercentage: 28654.4632, atlDate: "2013-07-06T00:00:00.000Z", lastUpdated: "2022-09-29T12:07:57.143Z", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 2.6355372761273657, currentHoldings: 3.0)
        
        sampleCoin2 = Coin(id: "ethernum", symbol: "eth", name: "Ethernum", image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579", currentPrice: 19488.51, marketCap: 373484860831, marketCapRank: 1.0, fullyDilutedValuation: 409270584218.0, totalVolume: 37170695130.0, high24H: 19704.08, low24H: 18971.94, priceChange24H: 500.44, priceChangePercentage24H: 2.63554, marketCapChange24H: 10118810515.0, marketCapChangePercentage24H: 2.78474, circulatingSupply: 19163806.0, totalSupply: 21000000.0, maxSupply: 21000000.0, ath: 69045.0, athChangePercentage: -71.76019, athDate: "2021-11-10T14:24:11.849Z", atl: 67.81, atlChangePercentage: 28654.4632, atlDate: "2013-07-06T00:00:00.000Z", lastUpdated: "2022-09-29T12:07:57.143Z", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 2.6355372761273657, currentHoldings: 3.0)
    }
    
    func testAddPortfolio() async throws {
        var updatedEntities: [any PortfolioEntityProtocol] = []
        
        //Create the stream
        let stream = try service.getPortfolio()
        // One coin with a positive amount - expects add
        let newEntities: [Coin: Double] = [sampleCoin1: 10]
        for  (_, amount) in newEntities.enumerated()
        {
            try service.updatePortfolio(coin: amount.key, amount: amount.value)
        }
        //Make a change
        updatedEntities = try await Task {
            var entities: [any PortfolioEntityProtocol] = []
            var initial = true
            for try await ent in stream {
                entities = ent
                if initial {
                    //The first call should be empty since you are using in Memory there is no permanent storage for testing
                    XCTAssert(entities.isEmpty)
                    initial = false
                } else {
                    break
                }
            }
            return entities
        }.value
        //Check that the updated value is correct
        //The values will be equal because we only expected additions
        XCTAssertEqual(newEntities.count, updatedEntities.count)
    }
    func testUpdatePortfolio() async throws {
        var updatedEntities: [any PortfolioEntityProtocol] = []
        var amount: Double = 10
        //Create the stream
        let stream = try service.getPortfolio()
        // One coin with a positive amount - expects add
        let newEntities: [Coin: Double] = [sampleCoin1: amount]
        for  (_, amount) in newEntities.enumerated()
        {
            try service.updatePortfolio(coin: amount.key, amount: amount.value)
        }
        //Make a change
        updatedEntities = try await Task {
            var entities: [any PortfolioEntityProtocol] = []
            var initial = true
            for try await ent in stream {
                entities = ent
                if initial {
                    //The first call should be empty since you are using in Memory there is no permanent storage for testing
                    XCTAssert(entities.isEmpty)
                    initial = false
                } else {
                    //Breaks after initial update
                    break
                }
            }
            return entities
        }.value
        //Check that the updated value is correct
        //Check that stored amount == expected amount
        XCTAssertEqual(updatedEntities.first?.amount, amount)
        //Change amount
        amount = 20
        //Create the stream
        let stream2 = try service.getPortfolio()
        // One coin with a positive amount - expects updated values
        let newEntities2: [Coin: Double] = [sampleCoin1: amount]
        for  (_, amount) in newEntities2.enumerated()
        {
            try service.updatePortfolio(coin: amount.key, amount: amount.value)
        }
        
        updatedEntities = try await Task {
            var entities: [any PortfolioEntityProtocol] = []
            var initial = true
            for try await ent in stream2 {
                entities = ent
                if initial {
                    //The first call should be empty since you are using in Memory there is no permanent storage for testing
                    XCTAssertEqual(entities.count, newEntities.count)
                    initial = false
                } else {
                    //Breaks on second update
                    break
                }
            }
            return entities
        }.value
        //First element amount is equal to updated amount
        XCTAssertEqual(updatedEntities.first?.amount, amount)
    }
    
    func testDelete() async throws {
        var updatedEntities: [any PortfolioEntityProtocol] = []
        let stream = try service.getPortfolio()
        // Once coin has a value of 10 - expect add
        // Once coin has a value of 0 - expect delete
        let newEntities: [Coin: Double] = [sampleCoin1: 10, sampleCoin2: 0]
        for  (_, amount) in newEntities.enumerated()
        {
            try service.updatePortfolio(coin: amount.key, amount: amount.value)
        }
        //Make a change
        
        updatedEntities = try await Task {
            var entities: [any PortfolioEntityProtocol] = []
            var initial = true
            for try await ent in stream {
                entities = ent
                if initial {
                    //The first call should be empty since you are using in Memory there is no permanent storage for testing
                    XCTAssert(entities.isEmpty)
                    initial = false
                } else {
                    //Breaks on second update
                    break
                }
            }
            return entities
        }.value
        //Check that the updated value is correct
        //the updated entities will have 1 coin because one was not added
        //value was zero so expected deletion.
        XCTAssertEqual(newEntities.count - 1, updatedEntities.count)
    }
}
