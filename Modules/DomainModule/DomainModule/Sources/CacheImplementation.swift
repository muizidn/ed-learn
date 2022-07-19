//
//  CacheImplementation.swift
//  Pods
//
//  Created by M on 19/07/22.
//

import Foundation

public struct LocalDocument {
    let token: String
    let status: Bool
    let enterprise: String?
}

public final class CacheLoadDocument {
    public enum RetrieveResult {
        case noCache
        case found(documents: [Document])
        case failure(Error)
    }
    
    public enum InsertResult {
        case success
        case failure(Error)
    }
    
    public enum RemoveResult {
        case success
        case failure(Error)
    }
    
    private let store: DocumentStore
    public init(store: DocumentStore) {
        self.store = store
    }
    
    public func retrieve(completion: @escaping (RetrieveResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .success(let docs):
                guard let docs = docs else  {
                    return completion(.noCache)
                }
                
                completion(.found(documents: docs.map({ Document(token: $0.token, status: $0.status, enterprise: $0.enterprise) })))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func insert(documents: [Document], completion: @escaping (InsertResult) -> Void) {
        store.insert(documents: documents.map { LocalDocument(token: $0.token, status: $0.status, enterprise: $0.enterprise) }) { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func remove(completion: @escaping (RemoveResult) -> Void) {
        store.remove { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public protocol DocumentStore {
    func retrieve(completion: @escaping (Result<[LocalDocument]?, Error>) -> Void)
    func insert(documents: [LocalDocument], completion: @escaping (Result<Void, Error>) -> Void)
    func remove(completion: @escaping (Result<Void, Error>) -> Void)
}

extension LocalDocument: Codable {}

public final class CodableDocumentStore: DocumentStore {
    private let fileURL: URL
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func retrieve(completion: @escaping (Result<[LocalDocument]?, Error>) -> Void) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return completion(.success(nil))
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let docs = try JSONDecoder().decode([LocalDocument].self, from: data)
            completion(.success(docs))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(documents: [LocalDocument], completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(documents)
            try data.write(to: self.fileURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func remove(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
