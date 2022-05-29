import XCTest

final class RemoteFeedLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
}

final class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }
}
