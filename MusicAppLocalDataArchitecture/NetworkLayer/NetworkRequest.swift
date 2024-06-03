//
//  NetworkRequest.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 19.05.24.
//

import Foundation

// MARK: - NetworkHTTPMethod

struct NetworkHTTPMethod: RawRepresentable, Equatable, Hashable {
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let get = NetworkHTTPMethod(rawValue: "GET")
}

// MARK: - NetworkRequest

final class NetworkRequest: NSObject {
        
    private var validStatusCodes = Set<Int>([200])
    
    private let baseURL: URL
    private let queue: DispatchQueue
    private let method: NetworkHTTPMethod
    
    init(
        url: URL,
        method: NetworkHTTPMethod,
        queue: DispatchQueue = .global()
    ) {
        self.baseURL = url
        self.method = method
        self.queue = queue
    }
    
    @discardableResult
    func createNetworkRequest() throws -> URLRequest {
        var r: URLRequest
        switch method {
        case .get:
            guard let components = URLComponents(string: baseURL.absoluteString) else {
                throw NetworkRequestError.badURL
            }
            guard let url = components.url else {
                throw NetworkRequestError.badURL
            }
            r = URLRequest(url: url)
        default:
            throw NetworkRequestError.unsupportedHTTPMethod
        }
        
        r.httpMethod = method.rawValue
        return r
    }
    
    @discardableResult
    func response(handler: @escaping (NetworkRequest.Response) -> Void) -> Self {
        
        let validStatusCodes = validStatusCodes
        let queue = queue
        
        do {
            var urlRequest = URLRequest(url: baseURL)
            urlRequest.httpMethod = method.rawValue
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                queue.async {
                    if error != nil {
                        handler(Response(error: .networkError))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        handler(Response(error: .ivalidResponse))
                        return
                    }
                    
                    guard validStatusCodes.contains(response.statusCode) else {
                        handler(Response(response: response, error: .ivalidResponse))
                        return
                    }
                    
                    guard let data = data else {
                        handler(Response(error: .noDataInResponse))
                        return
                    }
                    
                    handler(Response(data: data, response: response))
                }
            }
            
            task.resume()
            
            return self
        }
    }

    //the formUnion() method doesn't return any value. It inserts the elements of the given sequence into the set
    @discardableResult
    func validateStatusCodes(validStatusCodes:[Int]) -> Self {
        self.validStatusCodes.formUnion(validStatusCodes)
        return self
    }
}

extension NetworkRequest {
    enum NetworkRequestError : Error {
        case ivalidResponse
        case badURL
        case noDataInResponse
        case networkError
        case unsupportedHTTPMethod
        
        var customDescription: String {
            switch self {
            case .ivalidResponse:
                return "Invalid Request"
            case .badURL:
                return "Bad url"
            case .noDataInResponse:
                return "Not returned data"
            case .networkError:
                return "Network error"
            case .unsupportedHTTPMethod:
                return ""
            }
        }
    }
    
    struct Response {
        fileprivate (set) var data: Data? = nil
        fileprivate (set) var response: HTTPURLResponse? = nil
        fileprivate (set) var error: NetworkRequestError? = nil
    }
}
