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
    
    @MainActor func testHomeViewCoinsSearch() {
        viewModel.allCoins = [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave]
            
        // Search list
        viewModel.allCoinsSearchText = "bit"
        viewModel.filteredCoins = [MockCoin.bitcoin]
        //viewModel.sortCoins()
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin]) // first sorting (ordering)
    }
    
    @MainActor func testHomeViewCoinsSorted() {
        viewModel.allCoins = [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave]

        // The different ways of sorting
        viewModel.sortOption = .rank
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])
        
        viewModel.sortOption = .rankReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])
        
        viewModel.sortOption = .holdings
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])

        viewModel.sortOption = .holdingsReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])

        viewModel.sortOption = .price
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])

        viewModel.sortOption = .priceReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])
    }
    
    @MainActor func testPortfolioViewCoinsSearch() {
        viewModel.allCoins = [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave]
            
        // Search list
        viewModel.allCoinsSearchText = "bit"
        viewModel.portfolioCoins = [MockCoin.bitcoin]
        //viewModel.sortCoins()
        XCTAssertEqual(viewModel.portfolioViewCoins, [MockCoin.bitcoin]) // first sorting (ordering)
    }
    
    @MainActor func testPortfolioViewCoinsSorted() {
        viewModel.allCoins = [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave]

        // The different ways of sorting
        viewModel.sortOption = .rank
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])
        
        viewModel.sortOption = .rankReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])
        
        viewModel.sortOption = .holdings
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])

        viewModel.sortOption = .holdingsReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])

        viewModel.sortOption = .price
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.bitcoin, MockCoin.ethereum, MockCoin.aave])

        viewModel.sortOption = .priceReversed
        XCTAssertEqual(viewModel.homeViewCoins, [MockCoin.aave, MockCoin.ethereum, MockCoin.bitcoin])
    }
}
