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
    
    func test_notLoad_httpClientNotLoad() {
        let (_, httpClient) = makeSUT()
        
        XCTAssertTrue(httpClient.urls.isEmpty)
    }
    
    func test_loadTwice_httpClientLoadTwice() {
        let (sut, httpClient) = makeSUT()
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(httpClient.urls.count, 2)
    }
    
    func test_loadURL_httpClientLoadFromTheURLInCorrectOrder() {
        let httpClient = HTTPClient()
        let url1 = URL(string: "https://a-url.com")!
        let sut1 = RemoteLoadDocument(
            url: url1,
            httpClient: httpClient
        )
        
        sut1.load()
        
        let url2 = URL(string: "https://foo-url.com")!
        let sut2 = RemoteLoadDocument(
            url: url2,
            httpClient: httpClient
        )
        
        sut2.load()
        
        XCTAssertEqual(httpClient.urls, [url1, url2])
    }
    
    
    private func makeSUT() -> (sut: RemoteLoadDocument, client: HTTPClient){
        let httpClient = HTTPClient()
        let sut = RemoteLoadDocument(httpClient: httpClient)
        return (sut, httpClient)
    }
}
