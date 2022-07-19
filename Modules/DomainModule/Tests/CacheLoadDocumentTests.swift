//
//  CacheLoadDocumentTests.swift
//  Pods
//
//  Created by Muhammad Muizzsudin on 17/07/22.
//

import Foundation
import XCTest
import DomainModule

final class CacheLoadDocumentTests: XCTestCase {
    
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
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try! FileManager.default.removeItem(at: fileURL)
            FileManager.default.createFile(atPath: fileURL.path, contents: "[]".data(using: .utf8), attributes: nil)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffect()
    }
    
    private func undoStoreSideEffect() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try! FileManager.default.removeItem(at: fileURL)
    }
    
    func test_storeRetrieveEmpty_deliverRetrieveNoCache() {
        let sut = makeSUT()
        let exp = expectation(description: "load from store")
        
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.noCache])
    }
    
    func test_storeRetrieveNotEmpty_arrayDocumentEmpty_deliverFoundDocumentsValue() {
        let sut = makeSUT()
        let docsEmptyArray = [Document]()
        
        var exp = expectation(description: "insert to store")
        sut.insert(documents: docsEmptyArray, completion: { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: "load from store")
        
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docsEmptyArray)])
    }
    
    func test_storeRetrieveNotEmpty_deliverFoundDocumentsValue() {
        let sut = makeSUT()
        let docs = [Document(token: "token1", status: true, enterprise: nil)]
        
        var exp = expectation(description: "insert to store")
        sut.insert(documents: docs, completion: { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: "load from store")
        
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docs)])
    }
    
    func test_storeRetrieveError_deliverRetrieveError() {
        let sut = makeSUT()
        let exp = expectation(description: "load from store")
        let dontCareErrorJustEnsureFailureHappen = anyError()
        
        try! "invalid json".write(toFile: fileURL.path, atomically: true, encoding: .utf8)
        
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.failure(dontCareErrorJustEnsureFailureHappen)])
    }
    
    func test_storeInsertSuccess_deliverInsertSuccess() {
        let sut = makeSUT()
        var exp = expectation(description: "insert to store")
        let docs = [Document(token: "token1", status: true, enterprise: nil),
                    Document(token: "token1", status: true, enterprise: nil)]
        
        var insertResults = [CacheLoadDocument.InsertResult]()
        sut.insert(documents: docs) { result in
            insertResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(insertResults, [.success])
        
        
        exp = expectation(description: "load from store")
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docs)])
    }
    
    func test_insertInsertTwice_replacePreviouslyInsertedDocuments() {
        let sut = makeSUT()
        var exp = expectation(description: "insert to store")
        exp.expectedFulfillmentCount = 2
        
        let docs1 = [Document(token: "token1", status: true, enterprise: nil)]
        sut.insert(documents: docs1) { result in
            exp.fulfill()
        }
        
        let docs2 = [Document(token: "token2", status: true, enterprise: nil)]
        sut.insert(documents: docs2) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        
        exp = expectation(description: "load from store")
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrieveResults, [.found(documents: docs2)])
        
    }
    
    func test_storeInsertError_deliverInsertError() {
        let sut = makeSUT()
        let exp = expectation(description: "insert to store")
        let dontCareErrorJustEnsureFailureHappen = anyError()
        let readOnlyPermission = 777
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [.posixPermissions:readOnlyPermission])
        
        var results = [CacheLoadDocument.InsertResult]()
        sut.insert(documents: []) { result in
            results.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(dontCareErrorJustEnsureFailureHappen)])
    }
    
    func test_storeRemoveSuccess_deliverRemoveSuccess() {
        let sut = makeSUT()
        let docs = [Document(token: "token1", status: true, enterprise: nil),Document(token: "token2", status: true, enterprise: nil)]
        
        
        var exp = expectation(description: "insert to store")
        sut.insert(documents: docs) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        
        exp = expectation(description: "remove from store")
        var removeResults = [CacheLoadDocument.RemoveResult]()
        sut.remove { result in
            removeResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        exp = expectation(description: "load from store")
        var retrieveResults = [CacheLoadDocument.RetrieveResult]()
        sut.retrieve { result in
            retrieveResults.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(removeResults, [.success])
        XCTAssertEqual(retrieveResults, [.noCache])
    }
    
    func test_storeRemoveError_deliverRemoveError() {
        let sut = makeSUT()
        let exp = expectation(description: "remove from store")
        let dontCareErrorJustEnsureFailureHappen = anyError()
        
        createThenDeleteToEnsureFileNotExist()
        
        var results = [CacheLoadDocument.RemoveResult]()
        sut.remove { result in
            results.append(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(results, [.failure(dontCareErrorJustEnsureFailureHappen)])
    }
    
    private func createThenDeleteToEnsureFileNotExist() {
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        try! FileManager.default.removeItem(at: fileURL)
    }
    
    func test_sideEffect_runSerially() {
        let sut = makeSUT()
        let docs = [Document(token: "token1", status: true, enterprise: nil),
                    Document(token: "token2", status: false, enterprise: "Demo")]
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(documents: docs) { _ in
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.remove { _ in
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(documents: docs) { _ in
            op3.fulfill()
        }

        let op4 = expectation(description: "Operation 4")
        sut.retrieve { _ in
            op4.fulfill()
        }

        wait(for: [op1, op2, op3, op4], timeout: 5.0, enforceOrder: true)
    }

    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CacheLoadDocument {
        let store = CodableDocumentStore(fileURL: fileURL)
        let sut = CacheLoadDocument(store: store)
        
        trackMemory(sut, file: file, line: line)
        trackMemory(store, file: file, line: line)
        
        return sut
    }
}

extension CacheLoadDocument.RetrieveResult: Equatable {
    public static func == (lhs: CacheLoadDocument.RetrieveResult, rhs: CacheLoadDocument.RetrieveResult) -> Bool {
        switch (lhs, rhs) {
        case (.noCache, .noCache): return true
        case (.found(let docs), .found(let docs2)): return docs == docs2
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension CacheLoadDocument.InsertResult: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension CacheLoadDocument.RemoveResult: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}
