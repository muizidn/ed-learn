import XCTest

final class HTTPClient {
    static let shared = HTTPClient()
    
    func load() {
        
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
    
    func test_example() {
        
    }
}
