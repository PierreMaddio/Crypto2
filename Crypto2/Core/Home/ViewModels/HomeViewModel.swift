
import Foundation
import Combine


class HomeViewModel: ObservableObject {
    // anything subscribed to the this publisher will then get updated
    @Published var statistics: [Statistic] = []
    @Published var allCoins: [Coin] = []
    @Published var portfolioCoins: [Coin] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    @Published var sortOption: SortOption = .holdings
    
    // dataService initialize CoinDataService(), with init() get the coin automatically
    private let coinDataService: CoinDataServiceProtocol
    private let marketDataService: MarketDataServiceProtocol
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    init(coinDataService: CoinDataServiceProtocol = CoinDataService(), marketDataService: MarketDataServiceProtocol = MarketDataService()) {
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        addSubscribers()
    }
    
    func addSubscribers() {
        // updates allCoins
        $searchText
            .combineLatest($allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        // updates portfolio
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins) // the parameters are the same as the subscribers
            .sink { [weak self] (returnedCoins) in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        // updates marketData
        //        marketDataService.$marketData
        //            .combineLatest($portfolioCoins)
        //            .map(markGlobalMarketData)
        //            .sink { [weak self] (returnedStats) in
        //                self?.statistics = returnedStats
        //                self?.isLoading = false
        //            }
        //            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: Coin, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    @MainActor
    func reloadData() async throws{
        isLoading = true
        self.allCoins = try await coinDataService.getCoins()
        if let result = try? await marketDataService.getData() {
            let statistics = markGlobalMarketData(marketDataModel: result.data, portfolioCoins: self.allCoins)
            self.statistics = statistics
        }
        // device vibration
        HapticManager.notification(type: .success)
    }
    
    private func filterAndSortCoins(text: String, coins: [Coin], sort: SortOption) -> [Coin] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        // & inout indicator
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
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
    
    //    private func sortCoins(sort: SortOption, coins: [Coin]) -> [Coin] {
    //        switch sort {
    //        case .rank, .holdings:
    //            return coins.sorted { (coin1, coin2) -> Bool in
    //                return coin1.rank < coin2.rank
    //            }
    //        case .rankReversed, .holdingsReversed:
    //            return coins.sorted { (coin1, coin2) -> Bool in
    //                return coin1.rank > coin2.rank
    //            }
    //        case .price:
    //            return coins.sorted { (price1, price2) -> Bool in
    //                return price1.rank > price2.rank
    //            }
    //        case .priceReversed:
    //            return coins.sorted { (price1, price2) -> Bool in
    //                return price1.rank < price2.rank
    //            }
    //        }
    //    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [Coin]) -> [Coin] {
        // will only sort by holdings or reversed holdings if needed
        switch sortOption {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default:
            return coins
        }
    }
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [Coin], portfolioEntities: [PortfolioEntity]) -> [Coin] {
        allCoins
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
