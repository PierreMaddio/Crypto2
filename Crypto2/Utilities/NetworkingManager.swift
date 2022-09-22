
import Foundation
import Combine

class NetworkingManager: NetworkProtocol {
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        case invalidURLString
        var errorDescription: String? {
            switch self {
            case .invalidURLString: return "[🔥] Bad string for URL"
            case .badURLResponse(url: let url): return "[🔥] Bad response from URL: \(url)"
            case .unknown: return "[⚠️] Unknown error occured"
            }
        }
    }
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .eraseToAnyPublisher()
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLResponse(url: url)
        }
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case.finished:
            break
        case.failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func download(url: URL) async throws -> Data {
        let(data, response) = try await URLSession.shared.data(from: url)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)
        {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return data
    }
}

protocol NetworkProtocol {
    func download(url: URL) async throws -> Data
}

struct MockNetworkManager : NetworkProtocol {
    var data: Data?
    
    func download(url: URL) async throws -> Data {
        if Bool.random(){
            return self.data ?? " ".data(using: .utf8)!
        }else{
            throw NetworkingManager.NetworkingError.badURLResponse(url: url)
        }
    }
}
