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
        let store = DocumentStore()
        _ = LocalLoadDocument(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
}
