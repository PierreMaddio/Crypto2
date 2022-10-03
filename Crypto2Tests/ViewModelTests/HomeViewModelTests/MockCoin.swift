//
//  MockCoin.swift
//  Crypto2Tests
//
//  Created by Pierre on 03/10/2022.
//

@testable import Crypto2

class MockCoin {
    static var bitcoin = mockCoin(id: "bitcoin", symbol: "btc", name: "Bitcoin", marketCapRank: 1, holdings: 1, price: 10)
    static var ethereum = mockCoin(id: "ethereum", symbol: "eth", name: "Ethereum", marketCapRank: 2, holdings: 2, price: 5)
    static var aave = mockCoin(id: "aave", symbol: "aave", name: "Aave", marketCapRank: 3, holdings: 3, price: 2)
    
    static func mockCoin(id: String, symbol: String, name: String, marketCapRank: Double, holdings: Double, price: Double) -> Coin {
        return Coin(id: id, symbol: symbol, name: name, image: "", currentPrice: price, marketCap: 0, marketCapRank: marketCapRank, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "", atl: 0, atlChangePercentage: 0, atlDate: "", lastUpdated: "", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 0, currentHoldings: holdings)
    }
}
