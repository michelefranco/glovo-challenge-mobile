import Foundation

public enum APIError {
    case invalidURL(message: String)
    case failedRequest(message: String)
    case decodingJSON(message: String)
    
    var description: String {
        let error: String
        switch self {
        case .invalidURL(let message):
            error = message
        case .failedRequest(let message):
            error = message
        case .decodingJSON(let message):
            error = message
        }
        
        return error
    }
}

public enum APIResponse<T> {
    case success(result: T)
    case failure(error: APIError)
}
