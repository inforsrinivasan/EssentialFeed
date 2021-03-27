//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-25.
//

import Foundation

extension CoreDataFeedStore: FeedStore {

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context)
                    .map(context.delete)
                    .map(context.save)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

    public func insertFeed(feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedItem.items(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

    public func loadFeed(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed,
                                      timestamp: cache.timestamp)
                    )
                } else {
                    completion(.empty)
                }

            } catch(let error) {
                completion(.failure(error))
            }
        }
    }
    
}
