import Foundation
import Combine

protocol NetworkService {
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError>
    
    func upload<T: Decodable>(
        endpoint: Endpoint,
        data: Data,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError>
    
    func download(
        endpoint: Endpoint
    ) -> AnyPublisher<Data, NetworkError>
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let body: Data?
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
} 