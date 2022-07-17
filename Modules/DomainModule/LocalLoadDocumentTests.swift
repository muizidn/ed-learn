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
    
    func load() {
        store.retrieve()
    }
}

final class DocumentStore {
    enum Message {
        case retrieve
    }
    
    private(set) var messages: [Message] = []
    
    func retrieve() {
        messages.append(.retrieve)
    }
}

final class LocalLoadDocumentTests: XCTestCase {
    
    func test_onInit_notSendMessage() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_onLoadTwice_invokeStoreRetrieveTwice() {
        let (sut, store) = makeSUT()
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(store.messages, [.retrieve, .retrieve])
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalLoadDocument, store: DocumentStore) {
        let store = DocumentStore()
        let sut = LocalLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return (sut, store)
    }
}
