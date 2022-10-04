
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

enum GenericError: LocalizedError {
    case error(Error)
    
    var errorDescription: String? {
        switch self {
        case .error(let error):
            return error.localizedDescription
        }
    }
    
    var failureReason: String? {
        switch self {
        case .error(let error):
            let nsError = error as NSError
            return nsError.localizedFailureReason
        }
    }
    
    var helpAnchor: String? {
        switch self {
        case .error(let error):
            let nsError = error as NSError
            return nsError.helpAnchor
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .error(let error):
            let nsError = error as NSError
            return nsError.localizedRecoverySuggestion
        }
    }
}


