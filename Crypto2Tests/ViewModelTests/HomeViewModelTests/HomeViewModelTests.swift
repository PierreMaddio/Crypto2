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
        viewModel = HomeViewModel(coinDataService: mockCoinDataService, marketDataService: mockMarketDataService, portfolioDataService: MockPortfolioDataService(inMemory: true))
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
    
    @MainActor func testUpdatePortfolioAdd() async throws{
        // Retrieve all the coins
        let (allCoins, stat) = try await viewModel.reloadData()
        viewModel.allCoins = allCoins
        viewModel.statistics = stat
        
        // make sure all coins has values
        XCTAssertFalse(viewModel.allCoins.isEmpty)
        
        // Start listening but dont block the test from running. Mimicks .task in HomeView
        let task =  Task.detached{ [self] in try await viewModel.portfolioListener()}
        // Create a random amount
        let randomAmount = Double.random(in: 0..<100)
        
        let coin1 = MockCoin.aave
  
        // Update the coin with the amount
        try viewModel.updatePortfolio(coin: coin1, amount: randomAmount)
        
        // Wait for the database/viewModel.portfolioCoins to be updated
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Check and see if the coin was added
        let portCoints = viewModel.portfolioCoins.filter { coin in
            coin1.id == coin.id
        }
        // Make sure there is only one coin because coins should be unique
        XCTAssertEqual(portCoints.count, 1)
        // Verify the holding amount matches the amount
        XCTAssertEqual(portCoints.first?.currentHoldings, randomAmount)
        // Stop listening to changes in storage/CoreData
        task.cancel()
    }
    
    @MainActor func testUpdatePortfolioDelete() async throws{
        let (allCoins, stat) = try await viewModel.reloadData()
        viewModel.allCoins = allCoins
        viewModel.statistics = stat
        XCTAssertFalse(viewModel.allCoins.isEmpty)
        let task =  Task.detached{ [self] in try await viewModel.portfolioListener()}
        let randomAmount = Double.random(in: 0..<100)
        let coin1 = MockCoin.aave
  
        try viewModel.updatePortfolio(coin: coin1, amount: randomAmount)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        var portCoins = viewModel.portfolioCoins.filter { coin in
            coin1.id == coin.id
        }
        XCTAssertEqual(portCoins.count, 1)
        XCTAssertEqual(portCoins.first?.currentHoldings, randomAmount)
        
        // Set to zero for delete
        try viewModel.updatePortfolio(coin: coin1, amount: 0)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        portCoins = viewModel.portfolioCoins.filter { coin in
            coin1.id == coin.id
        }
        XCTAssertEqual(portCoins.count, 0)
        
        task.cancel()
    }
    
    @MainActor func testUpdatePortfolioUpdate() async throws{
        let (allCoins, stat) = try await viewModel.reloadData()
        viewModel.allCoins = allCoins
        viewModel.statistics = stat
        XCTAssertFalse(viewModel.allCoins.isEmpty)
        let task =  Task.detached{ [self] in try await viewModel.portfolioListener()}
        let randomAmount = Double.random(in: 0..<100)
        let coin1 = MockCoin.aave
  
        try viewModel.updatePortfolio(coin: coin1, amount: randomAmount)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        var portCoins = viewModel.portfolioCoins.filter { coin in
            coin1.id == coin.id
        }
        XCTAssertEqual(portCoins.count, 1)
        XCTAssertEqual(portCoins.first?.currentHoldings, randomAmount)
        let randomAmount2 = Double.random(in: 100..<200)
        // Change to new random amount
        try viewModel.updatePortfolio(coin: coin1, amount: randomAmount2)
        
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        portCoins = viewModel.portfolioCoins.filter { coin in
            coin1.id == coin.id
        }
        XCTAssertEqual(portCoins.count, 1)
        XCTAssertEqual(portCoins.first?.currentHoldings, randomAmount2)
        task.cancel()
    }
}
