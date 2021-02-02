//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-01-31.
//

import Foundation

internal final class FeedItemsMapper {

    private struct Root: Codable {
        let items: [RemoteFeedItem]

        var feed: [FeedItem] {
            return items.map { $0.item }
        }
    }

    private struct RemoteFeedItem: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    private static var OK_200: Int {
        return 200
    }

    internal static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }

}
