//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-01-31.
//

import Foundation

internal struct RemoteFeedItem: Codable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class FeedItemsMapper {

    private struct Root: Codable {
        let items: [RemoteFeedItem]
    }

    internal static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }

}
