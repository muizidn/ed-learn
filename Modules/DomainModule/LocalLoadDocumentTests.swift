//
//  LocalLoadDocumentTests.swift
//  Pods
//
//  Created by Muhammad Muizzsudin on 17/07/22.
//

import Foundation
import XCTest
import DomainModule

struct LocalDocument {
    let token: String
    let status: Bool
    let enterprise: String?
}

final class LocalLoadDocument {
    enum RetrieveResult {
        case empty
        case found(documents: [Document])
        case failure(Error)
    }
    
    enum InsertResult {
        case success
        case failure(Error)
    }
    
    enum RemoveResult {
        case success
        case failure(Error)
    }
    
    private let store: DocumentStore
    init(store: DocumentStore) {
        self.store = store
    }
    
    func retrieve(completion: @escaping (RetrieveResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .success(let docs):
                if docs.isEmpty {
                    completion(.empty)
                } else {
                    completion(.found(documents: docs.map({ Document(token: $0.token, status: $0.status, enterprise: $0.enterprise) })))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func insert(documents: [Document], completion: @escaping (InsertResult) -> Void) {
        store.insert(documents: documents.map { LocalDocument(token: $0.token, status: $0.status, enterprise: $0.enterprise) }) { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func remove(tokens: [String], completion: @escaping (RemoveResult) -> Void) {
        store.remove(tokens: tokens) { result in
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

protocol DocumentStore {
    func retrieve(completion: @escaping (Result<[LocalDocument], Error>) -> Void)
    func insert(documents: [LocalDocument], completion: @escaping (Result<Void, Error>) -> Void)
    func remove(tokens: [String], completion: @escaping (Result<Void, Error>) -> Void)
}

final class CodableDocumentStore: DocumentStore {
    private(set) var retrievalMessages: [(Result<[Document], Error>) -> Void] = []
    private(set) var insertMessages: [(Result<Void, Error>) -> Void] = []
    private(set) var removeMessages: [(Result<Void, Error>) -> Void] = []
    
    private let fileURL: URL
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func retrieve(completion: @escaping (Result<[LocalDocument], Error>) -> Void) {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                let docs = try JSONDecoder().decode([LocalDocument].self, from: data)
                completion(.success(docs))
            } else {
                completion(.success([]))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(documents: [LocalDocument], completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(documents)
            try data.write(to: fileURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func remove(tokens: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        retrieve { [unowned self] result in
            switch result {
            case .success(let docs):
                let filteredDocs = docs.filter { !tokens.contains($0.token) }
                insert(documents: filteredDocs) { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

final class LocalLoadDocumentTests: XCTestCase {
    
    private let fileURL = FileManager
        .default
        .urls(for: .cachesDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("documents.Test.json")
    
    override func setUp() {
        super.setUp()
        setStoreEmptyState()
    }
    
    private func setStoreEmptyState() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try! FileManager.default.removeItem(at: fileURL)
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffect()
    }
    
    private func undoStoreSideEffect() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try! FileManager.default.removeItem(at: fileURL)
    }
    
    func test_storeEmpty_deliverRetrieveEmpty() {
        let sut = makeSUT()
        let exp = expectation(description: "load from store")
        
        var retrieveResults = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.empty])
    }
    
    func test_storeNotEmpty_deliverFoundDocumentsValue() {
        let sut = makeSUT()
        let docs = [Document(token: "token1", status: true, enterprise: nil)]
        
        var exp = expectation(description: "insert to store")
        sut.insert(documents: docs, completion: { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: "load from store")
        
        var retrieveResults = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docs)])
    }
    
    func test_storeError_deliverRetrieveError() {
        let sut = makeSUT()
        let exp = expectation(description: "load from store")
        let error = anyError()
        
        try! "invalid json".write(toFile: fileURL.path, atomically: true, encoding: .utf8)
        
        var retrieveResults = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.failure(error)])
    }
    
    func test_storeSuccess_deliverInsertSuccess() {
        let sut = makeSUT()
        var exp = expectation(description: "insert to store")
        let docs = [Document(token: "token1", status: true, enterprise: nil)]
        
        var insertResults = [LocalLoadDocument.InsertResult]()
        sut.insert(documents: docs) { result in
            insertResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(insertResults, [.success])
        
        
        exp = expectation(description: "load from store")
        var retrieveResults = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docs)])
        
    }
    
    func test_storeError_deliverInsertError() {
        let sut = makeSUT()
        let exp = expectation(description: "insert to store")
        let dontCareErrorJustEnsureFailureHappen = anyError()
        let readOnlyPermission = 777
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [.posixPermissions:readOnlyPermission])
        
        var results = [LocalLoadDocument.InsertResult]()
        sut.insert(documents: []) { result in
            results.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(dontCareErrorJustEnsureFailureHappen)])
    }
    
    func test_storeSuccess_deliverRemoveSuccess() {
        let sut = makeSUT()
        let tokens = ["token1"]
        let docs = [Document(token: "token1", status: true, enterprise: nil),Document(token: "token2", status: true, enterprise: nil)]
        
        
        var exp = expectation(description: "insert to store")
        var insertResults = [LocalLoadDocument.InsertResult]()
        sut.insert(documents: docs) { result in
            insertResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(insertResults, [.success])
        
        
        exp = expectation(description: "remove from store")
        var removeResults = [LocalLoadDocument.RemoveResult]()
        sut.remove(tokens:  tokens) { result in
            removeResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(removeResults, [.success])
        
        exp = expectation(description: "load from store")
        var retrieveResults = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: [Document(token: "token2", status: true, enterprise: nil)])])
    }
    
    func test_storeError_deliverRemoveError() {
        let sut = makeSUT()
        let exp = expectation(description: "remove from store")
        let dontCareErrorJustEnsureFailureHappen = anyError()
        let readOnlyPermission = 777
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [.posixPermissions:readOnlyPermission])
        
        var results = [LocalLoadDocument.RemoveResult]()
        sut.remove(tokens: []) { result in
            results.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(dontCareErrorJustEnsureFailureHappen)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalLoadDocument {
        let store = CodableDocumentStore(fileURL: fileURL)
        let sut = LocalLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return sut
    }
}

extension LocalLoadDocument.RetrieveResult: Equatable {
    static func == (lhs: LocalLoadDocument.RetrieveResult, rhs: LocalLoadDocument.RetrieveResult) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case (.found(let docs), .found(let docs2)): return docs == docs2
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension LocalLoadDocument.InsertResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension LocalLoadDocument.RemoveResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension LocalDocument: Codable {}
