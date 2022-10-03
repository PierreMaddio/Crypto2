
import Foundation

class NetworkingManager {
    enum NetworkingError: LocalizedError, Error, Equatable {
        case badURLResponse
        case unknown
        case serverError
        case invalidURLString
        
        var errorDescription: String? {
            switch self {
            case .invalidURLString: return "[🔥] Bad string for URL"
            case .badURLResponse: return "[🔥] Bad response from URL"
            case .unknown: return "[⚠️] Unknown error occured"
            case .serverError : return "[🔥] Server Error"
            }
        }
    }
}


