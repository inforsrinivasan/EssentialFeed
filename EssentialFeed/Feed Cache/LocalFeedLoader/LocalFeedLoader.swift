//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-07.
//

import Foundation

public final class LocalFeedLoader {

    private let store: FeedStore
    private let currentTimestamp: () -> Date

    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentTimestamp = timestamp
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func loadFeed(completion: @escaping (LoadResult) -> Void) {
        store.loadFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .found(feed: let feed, timestamp: let timestamp) where FeedCachePolicy.validateTimestamp(timestamp, against: self.currentTimestamp()):
                completion(.success(feed.toModel()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func save(feed: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            guard error == nil else {
                completion(error)
                return
            }
            self.insert(feed: feed, timestamp: self.currentTimestamp(), completion: completion)
        }
    }

    private func insert(feed: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.insertFeed(feed: feed.toLocal(), timestamp: timestamp) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.loadFeed() {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed() { _ in }
            case .found(feed: _, timestamp: let timestamp) where !FeedCachePolicy.validateTimestamp(timestamp, against: self.currentTimestamp()):
                self.store.deleteCachedFeed() { _ in }
            case .empty, .found:
                break
            }
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedItem {
    func toModel() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
