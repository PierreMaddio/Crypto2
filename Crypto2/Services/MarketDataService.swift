
import Foundation

class MarketDataService: MarketDataServiceProtocol {
    //var networkManager: NetworkProtocol = NetworkingManager()
    
    // session to be used to make the API call
    let session: URLSession
    var urlString = "https://api.coingecko.com/api/v3/global"
    
    init(urlSession: URLSession = .shared) {
            self.session = urlSession
        }
    
    func getData() async throws -> GlobalData {
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingManager.NetworkingError.serverError
        }
        let decodedMarket = try JSONDecoder().decode(GlobalData.self, from: data)
        
        return decodedMarket
    }
}

protocol MarketDataServiceProtocol {
    func getData() async throws -> GlobalData
}


