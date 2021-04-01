//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-04-01.
//

public protocol FeedCache {
    func save(feed: [FeedItem], completion: @escaping (Error?) -> Void)
}
