//
//  HomeViewModelTests.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import XCTest
@testable import Crypto2

final class HomeViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    @MainActor func test1() {
        // given
        let mockCoinDataService = MockCoinDataService()
        let mockMarketDataService = MockMarketDataService()
        let viewModel = HomeViewModel(coinDataService: mockCoinDataService, marketDataService: mockMarketDataService)
        // when
        let isLoading = viewModel.isLoading
        // then
        XCTAssertEqual(isLoading, false)
    }
}
