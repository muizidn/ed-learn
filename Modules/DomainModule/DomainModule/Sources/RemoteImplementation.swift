//
//  RemoteImplementation.swift
//  Pods
//
//  Created by Muhammad Muizzsudin on 22/06/22.
//

import Foundation

public enum HTTPClientResponse {
    case data(Data)
    case error(Error)
}

public protocol HTTPClient {
    func load(url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}

public final class RemoteLoadDocument: LoadDocument {
    let httpClient: HTTPClient
    let url: URL
    
    public init(url: URL = URL(string: "https://a.com")!, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (LoadDocumentResult) -> Void) {
        httpClient.load(url: url) { response in
            switch response {
            case .data(let data):
                do {
                    let parsed = try JSONDecoder().decode([CodableDocument].self, from: data)
                    let documents = parsed.map({ Document(token: $0.token, status: $0.status, enterprise: $0.enterprise) })
                    completion(.success(documents))
                } catch {
                    completion(.failure(error))
                }
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
}

struct CodableDocument: Codable {
    let token: String
    let status: Bool
    let enterprise: String?
}
