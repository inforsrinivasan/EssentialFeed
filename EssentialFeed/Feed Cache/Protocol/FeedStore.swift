//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-07.
//

import Foundation

public enum RetrieveCacheFeedResult {
    case empty
    case found(feed: [LocalFeedItem], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    typealias RetrievalCompletion = (RetrieveCacheFeedResult)->Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertFeed(feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func loadFeed(completion: @escaping RetrievalCompletion)
}
