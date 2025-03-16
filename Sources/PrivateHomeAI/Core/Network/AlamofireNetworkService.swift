import Foundation
import Combine
import Alamofire

class AlamofireNetworkService: NetworkService {
    private let baseURL: URL
    private let session: Session
    
    init(baseURL: URL, session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        
        guard let finalURL = urlComponents?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        return session.request(request)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 401:
                    throw NetworkError.unauthorized
                case 400...499:
                    throw NetworkError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw NetworkError.serverError(httpResponse.statusCode)
                default:
                    throw NetworkError.requestFailed(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode)))
                }
                
                guard let data = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decodingFailed(decodingError)
                } else {
                    return NetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func upload<T: Decodable>(
        endpoint: Endpoint,
        data: Data,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let httpMethod: Alamofire.HTTPMethod
        switch endpoint.method {
        case .get:
            httpMethod = .get
        case .post:
            httpMethod = .post
        case .put:
            httpMethod = .put
        case .delete:
            httpMethod = .delete
        case .patch:
            httpMethod = .patch
        }
        
        return session.upload(data, to: url, method: httpMethod)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 401:
                    throw NetworkError.unauthorized
                case 400...499:
                    throw NetworkError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw NetworkError.serverError(httpResponse.statusCode)
                default:
                    throw NetworkError.requestFailed(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode)))
                }
                
                guard let data = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decodingFailed(decodingError)
                } else {
                    return NetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func download(
        endpoint: Endpoint
    ) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        
        guard let finalURL = urlComponents?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        return session.request(request)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 401:
                    throw NetworkError.unauthorized
                case 400...499:
                    throw NetworkError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw NetworkError.serverError(httpResponse.statusCode)
                default:
                    throw NetworkError.requestFailed(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode)))
                }
                
                guard let data = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                return data
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
} 