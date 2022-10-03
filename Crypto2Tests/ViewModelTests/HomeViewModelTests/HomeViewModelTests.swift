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

    @MainActor func testInitDefault() {
        // when
        let isLoading = viewModel.isLoading
        let allCoinsSearchText = viewModel.allCoinsSearchText
        let portfolioSearchText = viewModel.portfolioSearchText
        
        // then
        XCTAssertTrue(viewModel.statistics.isEmpty)
        XCTAssertTrue(viewModel.allCoins.isEmpty)
        XCTAssertTrue(viewModel.filteredCoins.isEmpty)
        XCTAssertTrue(viewModel.portfolioCoins.isEmpty)
        XCTAssertEqual(viewModel.sortOption, .holdings)
        XCTAssertEqual(isLoading, false)
        XCTAssertEqual(allCoinsSearchText, "")
        XCTAssertEqual(portfolioSearchText, "")
    }
}
