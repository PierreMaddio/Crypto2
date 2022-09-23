
import Foundation
import Combine

class CoinDetailDataService {
    @Published var coinDetails: CoinDetail? = nil
    
    var coinDetailSubscription: AnyCancellable?
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
        getCoinDetails()
    }
    
    func getCoinDetails() {
        // api coingecko: coins, coins/markets: usd, market_cap_desc, 250 results, 1, sparkline(true), 24h price change)
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else { return }
        
        coinDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetail.self, decoder: JSONDecoder()) // background thread to decode
            .receive(on: DispatchQueue.main) // back to main thread before sink
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoinDetails) in
                self?.coinDetails = returnedCoinDetails
                self?.coinDetailSubscription?.cancel()
            })
    }
}

/*
class CoinDetailDataService: CoinDetailDataServiceProtocol {
    var coinDetails: CoinDetail?
    
    var networkManager: NetworkProtocol = NetworkingManager()
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
    }
    
    func getCoinDetails() async throws -> CoinDetail {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        let coinDetail: CoinDetail = try await getObject(url: url)
        self.coinDetails = coinDetail
        return coinDetail
    }
    
    func getObject<C>(url: URL) async throws -> C where C : Codable {
        let data = try await networkManager.download(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(C.self, from: data)
    }
}

protocol CoinDetailDataServiceProtocol {
    func getCoinDetails() async throws -> CoinDetail
    var coinDetails: CoinDetail? { get set }
}

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    var networkManager: NetworkProtocol
    var coinDetails: CoinDetail?
    
    init(networkManager: NetworkProtocol, coinDetails: CoinDetail) {
        self.networkManager = networkManager
        self.coinDetails = coinDetails
    }
    
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
*/

/*
class CoinDetailDataService: CoinDetailDataServiceProtocol {
    var coinDetails: ObservableValue<CoinDetail?> = .init(nil)
    
    var networkManager: NetworkProtocol = NetworkingManager()
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
    }
    
    func getCoinDetails() async throws -> CoinDetail {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        let coinDetail: CoinDetail = try await getObject(url: url)
        self.coinDetails.value = coinDetail
        return coinDetail
    }
    
    func getObject<C>(url: URL) async throws -> C where C : Codable {
        let data = try await networkManager.download(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(C.self, from: data)
    }
}

protocol CoinDetailDataServiceProtocol {
    func getCoinDetails() async throws -> CoinDetail
    var coinDetails: ObservableValue<CoinDetail?> { get set }
}

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    var coinDetails: ObservableValue<CoinDetail?> = .init(nil)
    
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
*/
