import XCTest
import DomainModule

final class HTTPClientSpy: HTTPClient {
    var urls = [URL]()
    var completions = [(HTTPClientResponse) -> Void]()
    
    func load(url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        urls.append(url)
        completions.append(completion)
    }
    
    func completeWith(index: Int, response: HTTPClientResponse) {
        DispatchQueue.main.async { [unowned self] in
            self.completions[index](response)
        }
    }
}

final class RemoteLoadDocumentTests: XCTestCase {
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
    
    func test_loadURL_httpClientLoadFromTheURLInCorrectOrder() {
        let httpClient = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        let sut = RemoteLoadDocument(
            url: url,
            httpClient: httpClient
        )
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(httpClient.urls, [url, url])
    }
    
    func test_httpClientReturnData_LoadRemoteReturnsDocuments() {
        let (sut, httpClient) = makeSUT()
        

        let exp = expectation(description: "load documents")
        var resultDocuments = [Document]()
        sut.load { result  in
            switch result {
            case .success(let documents):
                resultDocuments = documents
                exp.fulfill()
            case .failure:
                break
            }
        }
        
        let json = [
            "token": "abc",
            "status": true,
            "enterprise": "foo"
        ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: [json], options: [])
        httpClient.completeWith(index: 0, response: .data(jsonData))
        
        wait(for: [exp], timeout: 10.0)

        XCTAssertEqual(resultDocuments, [Document(token: "abc", status: true, enterprise: "foo")])
    }
    
    func test_httpClientReturnData_LoadRemoteReturnsDocumentsInOrder() {
        let (sut, httpClient) = makeSUT()
        

        var result = [Document]()
        
        do {
            let exp = expectation(description: "load documents")
            sut.load { res in
                switch res {
                case .success(let array):
                    result += array
                    exp.fulfill()
                case .failure:
                    break
                }
            }
            
            let json = [
                "token": "abc",
                "status": true,
                "enterprise": "foo"
            ] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: [json], options: [])
            httpClient.completeWith(index: 0, response: .data(jsonData))
            
            wait(for: [exp], timeout: 10.0)
        }
        
        do {
            let exp = expectation(description: "load documents")
            sut.load { res in
                switch res {
                case .success(let array):
                    result += array
                    exp.fulfill()
                case .failure:
                    break
                }
            }
            
            let json = [
                "token": "def",
                "status": false,
                "enterprise": nil
            ] as [String : Any?]
            let jsonData = try! JSONSerialization.data(withJSONObject: [json], options: [])
            httpClient.completeWith(index: 1, response: .data(jsonData))
            
            wait(for: [exp], timeout: 10.0)
        }

        XCTAssertEqual(result, [
            Document(token: "abc", status: true, enterprise: "foo"),
            Document(token: "def", status: false, enterprise: nil)
        ])
    }
    
    func test_httpClientError_remoteLoadError() {
        let (sut, httpClient) = makeSUT()
        
        let error = anyError()
        
        let exp = expectation(description: "load documents then error")
        
        var errors = [NSError]()
        sut.load { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errors.append(error as NSError)
                exp.fulfill()
            }
        }
        httpClient.completeWith(index: 0, response: .error(error))
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertEqual(errors, [error])
    }
    
    
    private func makeSUT() -> (sut: RemoteLoadDocument, client: HTTPClientSpy){
        let httpClient = HTTPClientSpy()
        let sut = RemoteLoadDocument(httpClient: httpClient)
        return (sut, httpClient)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "httpclient", code: 1)
    }
}


extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }
}
