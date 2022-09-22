
import Foundation

class MarketDataService: MarketDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    
    func getData() async throws -> GlobalData {
        let urlString = "https://api.coingecko.com/api/v3/global"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        return try await getObject(url: url)
    }
    
    func getObject<C>(url: URL) async throws -> C where C : Codable {
        let data = try await networkManager.download(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(C.self, from: data)
    }
}

protocol MarketDataServiceProtocol {
    func getData() async throws -> GlobalData
}

/*
class MarketDataService {
    
    @Published var marketData: MarketData? = nil
    var marketDataSubscription: AnyCancellable?
    
    init() {
        getData()
    }
    
    func getData() {
        // api coingecko: coins, coins/markets: usd, market_cap_desc, 250 results, 1, sparkline(true), 24h price change)
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global"
        ) else { return }
        
        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder()) // background thread to decode
            .receive(on: DispatchQueue.main) // back to main thread before sink
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedGlobalData) in
                self?.marketData = returnedGlobalData.data
                self?.marketDataSubscription?.cancel()
            })
    }
}
*/
