//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-04-01.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Swift.Error>

    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
