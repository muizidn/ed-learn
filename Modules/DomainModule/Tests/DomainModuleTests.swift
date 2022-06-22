import XCTest

final class HTTPClient {
    var urls = [URL]()
    
    func load(url: URL) {
        urls.append(url)
    }
}

final class RemoteLoadDocument {
    let httpClient: HTTPClient
    let url: URL
    
    init(url: URL = URL(string: "https://a.com")!, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.load(url: url)
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
        let httpClient = HTTPClient()
        let sut = RemoteLoadDocument(httpClient: httpClient)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(httpClient.urls.count, 2)
    }
    
    func test_loadURL_httpClientLoadFromTheURL() {
        let httpClient = HTTPClient()
        let url = URL(string: "https://a-url.com")!
        let sut = RemoteLoadDocument(
            url: url,
            httpClient: httpClient
        )
        
        sut.load()
        
        XCTAssertEqual(httpClient.urls, [url])
    }
}
