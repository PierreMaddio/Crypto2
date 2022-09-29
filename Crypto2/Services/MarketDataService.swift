
import Foundation

class MarketDataService: MarketDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    
    // session to be used to make the API call
    let session: URLSession
    
    init(urlSession: URLSession = .shared) {
            self.session = urlSession
        }
    
    func getData() async throws -> GlobalData {
        let urlString = "https://api.coingecko.com/api/v3/global"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        let decodedMarket = try JSONDecoder().decode(GlobalData.self, from: data)
        
        return decodedMarket
        
        //return try await getObject(url: url)
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
