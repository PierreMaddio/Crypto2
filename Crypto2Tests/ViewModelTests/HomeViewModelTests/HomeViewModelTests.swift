//
//  HomeViewModelTests.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import XCTest
@testable import Crypto2

final class HomeViewModelTests: XCTestCase {
    var mockCoinDataService: MockCoinDataService!
    var mockMarketDataService: MockMarketDataService!
    var viewModel: HomeViewModel!
    
    @MainActor override func setUpWithError() throws {
        mockCoinDataService = MockCoinDataService()
        mockMarketDataService = MockMarketDataService()
        viewModel = HomeViewModel(coinDataService: mockCoinDataService, marketDataService: mockMarketDataService)
    }

    @MainActor func test1() {
        // when
        let isLoading = viewModel.isLoading
        // then
        XCTAssertEqual(isLoading, false)
    }
}
