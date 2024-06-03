//
//  NetworkManager.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 15.05.24.
//

import Foundation

enum APIResult<Success>{
    case success(Success)
    case failure(APIError)
}

internal struct APIError : Error, LocalizedError {
    let reason: String
    let message: String
    
    static func generalError(reason:String? = nil, message:String? = nil) -> APIError {
        APIError(
            reason: reason ?? NSLocalizedString("Error", comment: ""),
            message: message ?? NSLocalizedString("Something went wrong. Please try again!", comment: "")
        )
    }
    
    var errorDescription: String? {
        return message
    }
}
private struct ErrorResponse : Decodable {
    let code: String
    let description: String
    let errors: [ErrorResponse]?
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let server = "https://run.mocky.io/v3/93a5d6b5-f47a-40db-aca0-4824d955d330"
    
    lazy var validStatusCodes: [Int] = {
        var array = (200..<400).map{$0}
        return array
    }()
    
    
    func getArtists(completion: @escaping (APIResult<[ArtistModel]>) -> Void) {
        guard let serverURL = URL(string: "\(server)") else {
            return
        }
        NetworkRequest(
            url: serverURL,
            method: .get)
        .validateStatusCodes(validStatusCodes: validStatusCodes)
        .response { response in
            let responseResult: APIResult<[ArtistModel]> = self.handleResponseNew(response: response)
            DispatchQueue.main.async {
                completion(responseResult)
            }
        }
    }
    
    func getImageDataForArtist(url: URL, handler: @escaping (Result<Data, any Error>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                handler(.failure(error))
            } else if let data = data {
                handler(.success(data))
            }
        }.resume()
    }
}

private extension NetworkManager {
    
    func handleResponseNew<T>(response: NetworkRequest.Response) -> APIResult<T> where T : Decodable {
        if let error = response.error {
            print("Request failed with error \(error)")
        }
        
        guard
            let data = response.data, let responseCode = response.response?.statusCode
        else {
            return .failure(APIError.generalError())
        }
        
        do {
            switch (responseCode) {
            case 200..<400:
                let obj = try JSONDecoder().decode(T.self, from: data)
                return .success(obj)
            default:
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                return .failure(APIError(reason: "Error", message: errorResponse.description))
            }
        } catch {
            return .failure(APIError.generalError())
        }
    }
}
