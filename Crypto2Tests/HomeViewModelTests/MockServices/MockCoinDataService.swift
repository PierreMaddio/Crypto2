//
//  MockCoinDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 22/09/2022.
//

@testable import Crypto2

class MockCoinDataService: CoinDataServiceProtocol {
    var networkManager: NetworkProtocol = MockNetworkManager()
    
    func getCoins() async throws -> [Coin]{
        
        return await Task(operation: {
            return [Coin(id: "Sample", symbol: "Sample", name: "Sample", image: "Sample", currentPrice: 0, marketCap: 0, marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "Sample", atl: 0, atlChangePercentage: 0, atlDate: "Sample", lastUpdated: "Sample", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 0, currentHoldings: 0)]
        }).value
    }
}
