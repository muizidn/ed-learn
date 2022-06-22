import XCTest

final class HTTPClient {
    static let shared = HTTPClient()
    
    var loadCount = 0
    
    func load() {
        loadCount += 1
    }
}

final class RemoteLoadDocument {
    let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.load()
    }
}

final class DomainModuleTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_loadTwice_httpClientLoadTwice() {
        let httpClient = HTTPClient.shared
        let sut = RemoteLoadDocument(httpClient: httpClient)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(httpClient.loadCount, 2)
    }
}
