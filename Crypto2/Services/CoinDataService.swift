
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
    
    //    func getCoins() async throws -> [Coin] {
    //        print("\(#function) :: enter")
    //        guard let url = URL(string: urlString) else {
    //            throw NetworkingManager.NetworkingError.invalidURLString
    //        }
    //        print("\(#function) :: after url")
    //        let urlRequest = URLRequest(url: url)
    //        typealias Continuation = CheckedContinuation<[Coin], Error>
    //        return try await withCheckedThrowingContinuation({ continuation in
    //        let task = session.dataTask(with: urlRequest, completionHandler: { data, urlResponse, error in
    //            if let error = error {
    //                continuation.resume(throwing: error)
    //            } else {
    //                print("\(#function) :: after data request")
    //                guard (urlResponse as? HTTPURLResponse)?.statusCode == 200, let data = data else {
    //                    continuation.resume(throwing: NetworkingManager.NetworkingError.serverError)
    //                    return
    //                }
    //                do {
    //                    let decodedCoins = try JSONDecoder().decode([Coin].self, from: data)
    //                    print("\(#function) :: exit")
    //                    continuation.resume(returning: decodedCoins)
    //                } catch {
    //                    continuation.resume(throwing: error)
    //                }
    //            }
    //        })
    //            let _: NSKeyValueObservation = task.progress.observe(\.fractionCompleted){progress, _ in
    //                print(String(format: "\(#function) %0.2f", progress.fractionCompleted))
    //            }
    //            print("resume")
    //            task.resume()
    //            print(task.state.rawValue)
    //
    //        })
    //
    //    }
    //}
}

protocol CoinDataServiceProtocol {
    func getCoins() async throws -> [Coin]
}


