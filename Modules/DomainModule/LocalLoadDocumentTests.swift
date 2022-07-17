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
    private let store: DocumentStore
    init(store: DocumentStore) {
        self.store = store
    }
    
    func load(completion: @escaping (LoadDocumentResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .success(let docs):
                completion(.success(docs))
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
    
    func test_onLoadTwice_invokeStoreRetrieveTwice() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(store.messages.map { $0.type }, [.retrieve, .retrieve])
    }
    
    func test_storeEmpty_returnSuccessWithEmptyValue() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "load from store")
        
        var documents = [Document]()
        sut.load { result in
            switch result {
            case .success(let docs):
                documents = docs
                exp.fulfill()
            case .failure:
                break
            }
        }
        
        store.completeRetrival(idx: 0, with: .success([]))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(documents.isEmpty)
    }
    
    func test_storeNotEmpty_deliverDocumentsValue() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "load from store")
        
        var documents = [Document]()
        sut.load { result in
            switch result {
            case .success(let docs):
                documents = docs
                exp.fulfill()
            case .failure:
                break
            }
        }
        
        store.completeRetrival(idx: 0, with: .success([Document(token: "token1", status: true, enterprise: nil)]))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(documents, [Document(token: "token1", status: true, enterprise: nil)])
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalLoadDocument, store: DocumentStore) {
        let store = DocumentStore()
        let sut = LocalLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return (sut, store)
    }
}
