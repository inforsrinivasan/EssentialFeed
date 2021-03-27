//
//  CoreDataFeedStore+FeedImaageDataLoader.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-24.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedItem.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedItem.first(with: url, in: context)?.data
            })
        }
    }

}
