
import Foundation

class CoinDetailDataService: CoinDetailDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    let coin: Coin
    
    // session to be used to make the API call
    let session: URLSession
    
    init(coin: Coin, urlSession: URLSession = .shared) {
        self.coin = coin
        self.session = urlSession
    }
    
    func getCoinDetails() async throws -> CoinDetail {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        let decodedCoinDetails = try JSONDecoder().decode(CoinDetail.self, from: data)
        
        return decodedCoinDetails
    }
}

protocol CoinDetailDataServiceProtocol {
    func getCoinDetails() async throws -> CoinDetail
}


