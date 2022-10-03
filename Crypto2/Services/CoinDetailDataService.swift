
import Foundation

class CoinDetailDataService: CoinDetailDataServiceProtocol {
    let coin: Coin
    
    // session to be used to make the API call
    let session: URLSession
    
    // A lazy stored property is a property whose initial value is not calculated until the first time it is used, it is why a can use coin.id(before init)
    lazy var urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false"
    
    init(coin: Coin, urlSession: URLSession = .shared) {
        self.coin = coin
        self.session = urlSession
    }
    
    func getCoinDetails() async throws -> CoinDetail {
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingManager.NetworkingError.serverError
        }
        let decodedCoinDetails = try JSONDecoder().decode(CoinDetail.self, from: data)
        
        return decodedCoinDetails
    }
}

protocol CoinDetailDataServiceProtocol {
    func getCoinDetails() async throws -> CoinDetail
}


