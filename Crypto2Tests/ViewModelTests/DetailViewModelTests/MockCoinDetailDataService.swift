//
//  MockCoinDetailDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import Foundation
@testable import Crypto2

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()

    func getCoinDetails() async throws -> CoinDetail {
        return await Task(operation: {
            return CoinDetail(
                id: "Sample",
                symbol: "Sample",
                name: "Sample",
                blockTimeInMinutes: 0,
                hashingAlgorithm: "Sample",
                description: nil,
                links: nil
            )
        }).value
    }
}
