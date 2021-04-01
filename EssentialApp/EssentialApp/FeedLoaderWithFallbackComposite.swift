//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Srinivasan Rajendran on 2021-03-29.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {

    private let primary: FeedLoader
    private let fallback: FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {

        primary.loadFeed { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.loadFeed(completion: completion)
            }
        }
    }
}
