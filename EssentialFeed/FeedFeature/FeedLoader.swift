//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-01-24.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>
public protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
