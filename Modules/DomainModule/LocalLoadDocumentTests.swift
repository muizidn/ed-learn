//
//  LocalLoadDocumentTests.swift
//  Pods
//
//  Created by Muhammad Muizzsudin on 17/07/22.
//

import Foundation
import XCTest
import DomainModule

final class LocalLoadDocument {
    enum RetrieveResult {
        case empty
        case found(documents: [Document])
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
}

final class DocumentStore {
    struct Message {
        enum MsgType {
            case retrieve
        }
        let type: MsgType
        let completion: (Result<[Document], Error>) -> Void
    }
    
    private(set) var messages: [Message] = []
    
    func retrieve(completion: @escaping (Result<[Document], Error>) -> Void) {
        messages.append(.init(type: .retrieve, completion: completion))
    }
    
    func completeRetrival(idx: Int, with result: Result<[Document], Error>) {
        messages[idx].completion(result)
    }
}

final class LocalLoadDocumentTests: XCTestCase {
    
    func test_onInit_notSendMessage() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_onRetrieveTwice_invokeStoreRetrieveTwice() {
        let (sut, store) = makeSUT()
        
        sut.retrieve { _ in }
        sut.retrieve { _ in }
        
        XCTAssertEqual(store.messages.map { $0.type }, [.retrieve, .retrieve])
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
