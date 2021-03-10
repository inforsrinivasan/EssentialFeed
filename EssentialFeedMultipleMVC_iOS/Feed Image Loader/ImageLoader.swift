//
//  ImageLoader.swift
//  EssentialFeedMultipleMVC_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-03.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
