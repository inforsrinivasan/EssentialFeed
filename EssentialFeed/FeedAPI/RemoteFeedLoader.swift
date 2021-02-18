//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-01-24.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {

    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func loadFeed(completion: @escaping (Result) -> Void) {
        client.get(url: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data: data, response: response)
            return .success(items.toModel())
        } catch(let error) {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModel() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
