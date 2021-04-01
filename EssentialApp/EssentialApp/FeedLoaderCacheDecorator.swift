//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Srinivasan Rajendran on 2021-04-01.
//

import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {

    private let decoratee: FeedLoader
    private let cache: FeedCache

    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        decoratee.loadFeed { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedItem]) {
        save(feed: feed) { _ in }
    }
}
