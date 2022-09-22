
import Foundation

class CoinDataService: CoinDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    
    func getCoins() async throws -> [Coin] {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h"
        guard let url = URL(string: urlString) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        return try await getObject(url: url)
    }
    
    ///The function is used to fetch and decode any resource, given the url.
    ///It uses networkManager.downloar(url:) function to do the api call
    ///The result is of type Data.
    ///The JSONDecoder is then used to decode it.
    ///JSONDecoder requires you specify a class type to decode the Data into.
    ///That's where C.self in the decode(:from:) function comes in.
    func getObject<C>(url: URL) async throws -> C where C : Codable {
        let data = try await networkManager.download(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(C.self, from: data)
    }
}

protocol CoinDataServiceProtocol{
    func getCoins() async throws -> [Coin]
}

class MockCoinDataService: CoinDataServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    
    func getCoins() async throws -> [Coin]{
        
        return await Task(operation: {
            return [Coin(id: "Sample", symbol: "Sample", name: "Sample", image: "Sample", currentPrice: 0, marketCap: 0, marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "Sample", atl: 0, atlChangePercentage: 0, atlDate: "Sample", lastUpdated: "Sample", sparklineIn7D: nil, priceChangePercentage24HInCurrency: 0, currentHoldings: 0)]
        }).value
    }
}
