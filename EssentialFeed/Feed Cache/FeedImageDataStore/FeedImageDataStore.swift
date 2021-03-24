//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetreivalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetreivalResult) -> Void)
}
