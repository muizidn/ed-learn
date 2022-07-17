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
                    completion(.found(documents: docs))
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
}

final class DocumentStore {
    private(set) var retrievalMessages: [(Result<[Document], Error>) -> Void] = []
    private(set) var insertMessages: [(Result<Void, Error>) -> Void] = []
    
    func retrieve(completion: @escaping (Result<[Document], Error>) -> Void) {
        retrievalMessages.append(completion)
    }
    
    func completeRetrival(idx: Int, with result: Result<[Document], Error>) {
        retrievalMessages[idx](result)
    }
    
    func insert(documents: [LocalDocument], completion: @escaping (Result<Void, Error>) -> Void) {
        insertMessages.append(completion)
    }
    
    func completeInsert(idx: Int, with result: Result<Void, Error>) {
        insertMessages[idx](result)
    }
}

final class LocalLoadDocumentTests: XCTestCase {
    
    func test_onInit_notSendMessage() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.retrievalMessages.isEmpty)
        XCTAssertTrue(store.insertMessages.isEmpty)
    }
    
    func test_onRetrieveTwice_invokeStoreRetrieveTwice() {
        let (sut, store) = makeSUT()
        
        sut.retrieve { _ in }
        sut.retrieve { _ in }
        
        XCTAssertEqual(store.retrievalMessages.count, 2)
    }
    
    func test_storeEmpty_deliverRetrieveEmpty() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "load from store")
        
        var results = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            results.append(result)
            exp.fulfill()
        }
        
        store.completeRetrival(idx: 0, with: .success([]))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.empty])
    }
    
    func test_storeNotEmpty_deliverFoundDocumentsValue() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "load from store")
        
        var results = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            results.append(result)
            exp.fulfill()
        }
        
        store.completeRetrival(idx: 0, with: .success([Document(token: "token1", status: true, enterprise: nil)]))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.found(documents: [Document(token: "token1", status: true, enterprise: nil)])])
    }
    
    func test_storeError_deliverRetrieveError() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "load from store")
        let error = anyError()
        
        var results = [LocalLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            results.append(result)
            exp.fulfill()
        }
        
        store.completeRetrival(idx: 0, with: .failure(error))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(error)])
    }
    
    func test_onInsertTwice_invokeStoreInsertTwice() {
        let (sut, store) = makeSUT()
        
        sut.insert(documents: []) { _ in }
        sut.insert(documents: []) { _ in }
        
        XCTAssertEqual(store.insertMessages.count, 2)
    }
    
    func test_storeSuccess_deliverInsertSuccess() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "insert to store")
        let docs = [Document(token: "token1", status: true, enterprise: nil)]
        
        var results = [LocalLoadDocument.InsertResult]()
        sut.insert(documents: docs) { result in
            results.append(result)
            exp.fulfill()
        }
        
        store.completeInsert(idx: 0, with: .success(()))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.success])
    }
    
    func test_storeError_deliverInsertError() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "insert to store")
        let error = anyError()
        
        var results = [LocalLoadDocument.InsertResult]()
        sut.insert(documents: []) { result in
            results.append(result)
            exp.fulfill()
        }
        
        store.completeInsert(idx: 0, with: .failure(error))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(error)])
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalLoadDocument, store: DocumentStore) {
        let store = DocumentStore()
        let sut = LocalLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return (sut, store)
    }
}

extension LocalLoadDocument.RetrieveResult: Equatable {
    static func == (lhs: LocalLoadDocument.RetrieveResult, rhs: LocalLoadDocument.RetrieveResult) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }
}

extension LocalLoadDocument.InsertResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }
}
