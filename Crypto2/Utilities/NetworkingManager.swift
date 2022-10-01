
import Foundation

class NetworkingManager {
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        case serverError
        case invalidURLString
        
        var errorDescription: String? {
            switch self {
            case .invalidURLString: return "[🔥] Bad string for URL"
            case .badURLResponse(url: let url): return "[🔥] Bad response from URL: \(url)"
            case .unknown: return "[⚠️] Unknown error occured"
            case .serverError : return "[🔥] Server Error"
            }
        }
    }
}


