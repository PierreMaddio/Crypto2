
import Foundation

class CoinDataService: CoinDataServiceProtocol {
    // session to be used to make the API call
    let session: URLSession
    
    var urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h"
    
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    func getCoins() async throws -> [Coin] {
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingManager.NetworkingError.serverError
        }
        let decodedCoins = try JSONDecoder().decode([Coin].self, from: data)
        
        return decodedCoins
    }
}

protocol CoinDataServiceProtocol{
    func getCoins() async throws -> [Coin]
}

