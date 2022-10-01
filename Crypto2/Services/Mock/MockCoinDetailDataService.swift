//
//  MockCoinDetailDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import Foundation
//@testable import Crypto2

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
    }
    func getCoinDetails() async throws -> CoinDetail {
        return await Task(operation: {
            return CoinDetail(
                id: coin.id,
                symbol: coin.symbol,
                name: coin.name,
                blockTimeInMinutes: 10,
                hashingAlgorithm: "SHA-256",
                description: nil,
                links: nil
            )
        }).value
    }
}
