
import Foundation
import Combine


class HomeViewModel: ObservableObject {
    private let coinDataService: CoinDataServiceProtocol
    private var marketDataService: MarketDataServiceProtocol
    private let portfolioDataService: PortfolioDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // anything subscribed to the these publishers will then get updated
    @Published var statistics: [Statistic] = []
    @Published var isLoading: Bool = false
    @Published var allCoinsSearchText: String = ""
    @Published var portfolioSearchText: String = ""
    @Published var allCoins: [Coin] = [] // All 250
    @Published var filteredCoins: [Coin] = [] // After a search
    @Published var portfolioCoins: [Coin] = [] // Saved portfolio
    
    @Published var sortOption: SortOption = .holdings
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    // Show on the home page
    var homeViewCoins: [Coin] {
        // searching, show only searched coins
        if !allCoinsSearchText.isEmpty {
            return filteredCoins
        }
        // sorting, show only sorted coins
        switch sortOption {
        case .rank, .holdings:
            return allCoins.sorted(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            return allCoins.sorted(by: { $0.rank > $1.rank })
        case .price:
            return allCoins.sorted(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            return allCoins.sorted(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    var portfolioViewCoins: [Coin] {
        // searching, show only searched coins
        if !allCoinsSearchText.isEmpty {
            return portfolioCoins
        }
        // else show filteredPortfolioCoins
        
        // sorting, show only portfolio sorted coins
        switch sortOption {
        case .rank, .holdings:
            return portfolioCoins.sorted(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            return portfolioCoins.sorted(by: { $0.rank > $1.rank })
        case .price:
            return portfolioCoins.sorted(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            return portfolioCoins.sorted(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    init(coinDataService: CoinDataServiceProtocol = CoinDataService(), marketDataService: MarketDataServiceProtocol = MarketDataService(), portfolioDataService:  PortfolioDataServiceProtocol = PortfolioDataService()) {
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        self.portfolioDataService = portfolioDataService
        addSubscribers()
    }
    
    func addSubscribers() {
        // updates allCoins
        $allCoinsSearchText
            .combineLatest($allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.filteredCoins = returnedCoins
            }
            .store(in: &cancellables)
        $portfolioSearchText
            .combineLatest($portfolioCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.filteredCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: Coin, amount: Double) throws {
        try portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    @MainActor
    func portfolioListener() async throws  {
        let stream = try portfolioDataService.getPortfolio()
        
        for await entities in stream {
            self.portfolioCoins = mapAllCoinsToPortfolioCoins(allCoins: allCoins, portfolioEntities: entities)
            let result = try await marketDataService.getData()
            let statistics = markGlobalMarketData(marketDataModel: result.data, portfolioCoins: portfolioCoins)
            self.statistics = statistics
        }
    }
    
    @MainActor
    func reloadData() async throws -> (allCoins: [Coin],statistics: [Statistic]) {
        isLoading = true
        
        let allCoins = try await coinDataService.getCoins()
        let result = try await marketDataService.getData()
        let statistics = markGlobalMarketData(marketDataModel: result.data, portfolioCoins: portfolioCoins)
        self.statistics = statistics
        
        // device vibration
        HapticManager.notification(type: .success)
        isLoading = false
        return (allCoins, statistics)
    }
    
    private func filterAndSortCoins(text: String, coins: [Coin], sort: SortOption) -> [Coin] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        // & inout indicator
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
    }
    
    // inout: we take in the array of Coin and return out the same array of Coin, and sort do not create a new array
    private func sortCoins(sort: SortOption, coins: inout [Coin]) {
        switch sort {
        case .rank, .holdings:
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    private func filterCoins(text: String, coins: [Coin]) -> [Coin] {
        guard !text.isEmpty else {
            return coins
        }
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) || coin.symbol.lowercased().contains(lowercasedText) || coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [Coin], portfolioEntities: [PortfolioEntityProtocol]) -> [Coin] {
        return allCoins
            .compactMap { (coin) -> Coin? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    private func markGlobalMarketData(marketDataModel: MarketData?, portfolioCoins: [Coin]) -> [Statistic] {
        var stats: [Statistic] = []
        
        guard let data = marketDataModel else {
            return stats
        }
        
        let marketCap = Statistic(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = Statistic(title: "24h Volume", value: data.volume)
        let btcDominance = Statistic(title: "BTC Dominance", value: data.btcDominance)
        
        let portfolioValue =
        portfolioCoins
            .map({ $0.currentHoldingsValue })
            .reduce(0, +)
        
        let previousValue =
        portfolioCoins
            .map { (coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percenChange = (coin.priceChangePercentage24H ?? 0)  / 100
                let previousValue = currentValue / (1 + percenChange)
                return previousValue
            }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio = Statistic(
            title: "Portfolio Value",
            value: portfolioValue.asCurrencyWith2Decimals(),
            percentageChange: percentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        return stats
    }
}
