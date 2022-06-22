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
    
    func completeWithData(index: Int, data: Data) {
        DispatchQueue.main.async { [unowned self] in
            self.completions[index](.data(data))
        }
    }
    
    func completeWithError(index: Int, error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.completions[index](.error(error))
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
    
    enum LoadDocumentResult {
        case success([Document])
        case failure(Error)
    }
    
    func load(completion: @escaping (LoadDocumentResult) -> Void) {
        httpClient.load(url: url) { response in
            switch response {
            case .data(let data):
                let parsed = try! JSONDecoder().decode([CodableDocument].self, from: data)
                let documents = parsed.map({ Document(token: $0.token, status: $0.status, enterprise: $0.enterprise) })
                completion(.success(documents))
            case .error(let error):
                completion(.failure(error))
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
        httpClient.completeWithData(index: 0, data: jsonData)
        
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
            httpClient.completeWithData(index: 0, data: jsonData)
            
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
            httpClient.completeWithData(index: 1, data: jsonData)
            
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
        httpClient.completeWithError(index: 0, error: error)
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertEqual(errors, [error])
    }
    
    
    private func makeSUT() -> (sut: RemoteLoadDocument, client: HTTPClient){
        let httpClient = HTTPClient()
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
