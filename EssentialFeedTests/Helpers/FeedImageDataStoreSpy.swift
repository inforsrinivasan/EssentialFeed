//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-03-24.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {

    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case save(dataFor: URL)
    }

    private var retrievalCompletions = [(FeedImageDataStore.RetreivalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    var receivedMessages = [Message]()

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
        receivedMessages.append(Message.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func completeRetreival(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetreival(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.save(dataFor: url))
        insertionCompletions.append(completion)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completionInsertionSuccessFully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
