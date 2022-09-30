//
//  MockMarketDataService.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

@testable import Crypto2

class MockMarketDataService: MarketDataServiceProtocol {
    func getData() async throws -> GlobalData {
        return await Task(operation: {
            return GlobalData(data: MarketData(
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
                marketCapChangePercentage24HUsd: -0.6016048565865182))
        }).value
    }
}
