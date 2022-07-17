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
        store.load()
    }
}

final class DocumentStore {
    enum Message {
        case load
    }
    
    private(set) var messages: [Message] = []
    
    func load() {
        messages.append(.load)
    }
}

final class LocalLoadDocumentTests: XCTestCase {
    
    func test_onInit_notSendMessage() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalLoadDocument, store: DocumentStore) {
        let store = DocumentStore()
        let sut = LocalLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return (sut, store)
    }
}
