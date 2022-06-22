import XCTest
import DomainModule

final class HTTPClient {
    var urls = [URL]()
    var completions = [(HTTPClientResponse) -> Void]()
    
    enum HTTPClientResponse {
        case data(Data)
        case error(Error)
    }
    
    func load(url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        urls.append(url)
        completions.append(completion)
    }
    
    func completeWithData(data: Data) {
        DispatchQueue.main.async { [unowned self] in
            self.completions[0](.data(data))
        }
    }
}

final class RemoteLoadDocument {
    let httpClient: HTTPClient
    let url: URL
    
    init(url: URL = URL(string: "https://a.com")!, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load(completion: @escaping ([Document]) -> Void) {
        httpClient.load(url: url) { response in
            switch response {
            case .data(let data):
                let parsed = try! JSONDecoder().decode([CodableDocument].self, from: data)
                completion(parsed.map({ Document(token: $0.token, status: $0.status, enterprise: $0.enterprise) }))
            case .error(let error):
                break
            }
        }
    }
}

struct CodableDocument: Codable {
    let token: String
    let status: Bool
    let enterprise: String?
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
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(httpClient.urls.count, 2)
    }
    
    func test_loadURL_httpClientLoadFromTheURLInCorrectOrder() {
        let httpClient = HTTPClient()
        let url1 = URL(string: "https://a-url.com")!
        let sut1 = RemoteLoadDocument(
            url: url1,
            httpClient: httpClient
        )
        
        sut1.load { _ in }
        
        let url2 = URL(string: "https://foo-url.com")!
        let sut2 = RemoteLoadDocument(
            url: url2,
            httpClient: httpClient
        )
        
        sut2.load { _ in }
        
        XCTAssertEqual(httpClient.urls, [url1, url2])
    }
    
    func test_httpClientReturnData_LoadRemoteReturnsDocuments() {
        let (sut, httpClient) = makeSUT()
        

        let exp = expectation(description: "load documents")
        var result = [Document]()
        sut.load { documents in
            result = documents
            exp.fulfill()
        }
        
        let json = [
            "token": "abc",
            "status": true,
            "enterprise": "foo"
        ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: [json], options: [])
        httpClient.completeWithData(data: jsonData)
        
        wait(for: [exp], timeout: 10.0)

        XCTAssertEqual(result, [Document(token: "abc", status: true, enterprise: "foo")])
    }
    
    
    private func makeSUT() -> (sut: RemoteLoadDocument, client: HTTPClient){
        let httpClient = HTTPClient()
        let sut = RemoteLoadDocument(httpClient: httpClient)
        return (sut, httpClient)
    }
}


extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }
}
