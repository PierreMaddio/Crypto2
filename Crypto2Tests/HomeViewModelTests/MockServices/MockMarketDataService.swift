//
//  MockMarketDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

@testable import Crypto2

class MockMarketDataService: MarketDataServiceProtocol {
    var networkManager: NetworkProtocol = MockNetworkManager()
    
    func getData() async throws -> GlobalData {
        return await Task(operation: {
            return GlobalData(data: MarketData(totalMarketCap: ["Sample": 0], totalVolume: ["Sample": 0], marketCapPercentage: ["Sample": 0], marketCapChangePercentage24HUsd: 0))
        }).value
    }
}
