//
//  RemoteFeedLoader.swift
//  AppHost-EssentialFeedUI-Unit-Tests
//
//  Created by Muiz on 29/05/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}

public protocol HTTPClient {
    func get(from: URL)
}
