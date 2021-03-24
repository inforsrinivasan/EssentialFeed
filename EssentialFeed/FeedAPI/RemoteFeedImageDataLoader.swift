//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-20.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {

    private var client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(client: HTTPClient) {
        self.client = client
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(url: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                if response.isOK, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        })
        return task
    }

}

private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {

    private var completion: ((FeedImageDataLoader.Result) -> Void)?

    var wrapped: HTTPClientTask?

    init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        self.completion = completion
    }

    func complete(with result: FeedImageDataLoader.Result) {
        completion?(result)
    }

    func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
    }

    private func preventFurtherCompletions() {
        completion = nil
    }
}
