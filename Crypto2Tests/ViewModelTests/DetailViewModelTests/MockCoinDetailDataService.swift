//
//  MockCoinDetailDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import Foundation
@testable import Crypto2

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    func getCoinDetails() async throws -> CoinDetail {
        return await Task(operation: {
            return CoinDetail(
                id: "bitcoin",
                symbol: "btc",
                name: "Bitcoin",
                blockTimeInMinutes: 10,
                hashingAlgorithm: "SHA-256",
                description: nil,
                links: nil
            )
        }).value
    }
}
