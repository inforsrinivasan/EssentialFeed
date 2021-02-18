//
//  LocalFeedLoader.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-02-06.
//

import XCTest
import EssentialFeed

final class SaveFeedToCacheUseCaseTests: XCTestCase {

    // saving cache

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(feed: [anyFeeditem().model, anyFeeditem().model]) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doestNotRequestInsertion_onDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(feed: [anyFeeditem().model, anyFeeditem().model]) { _ in }
        store.completeDeletion(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsNewCacheInsertionWithTimestamp_onDeletionSuccess() {
        let timestamp = Date.init()
        let (sut, store) = makeSUT(timestamp: { timestamp })
        let feed1 = anyFeeditem()
        let feed2 = anyFeeditem()
        sut.save(feed: [feed1.model, feed2.model]) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert([feed1.local, feed2.local], timestamp)])
    }

    func test_save_fails_onDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        let exp = expectation(description: "wait for save completion")
        sut.save(feed: [anyFeeditem().model, anyFeeditem().model]) { error in
            XCTAssertEqual(error as NSError?, deletionError)
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
    }

    func test_save_fails_onInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        let exp = expectation(description: "wait for save completion")
        sut.save(feed: [anyFeeditem().model, anyFeeditem().model]) { error in
            XCTAssertEqual(error as NSError?, insertionError)
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
    }

    func test_save_completesSuccessfully() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "wait for save completion")
        sut.save(feed: [anyFeeditem().model, anyFeeditem().model]) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }

    func test_save_doesNotDeliverResultOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { return Date.init() })
        var receivedResults = [Error?]()

        sut?.save(feed: [anyFeeditem().model]) { error in
            receivedResults.append(error)
        }
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorOnInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { return Date.init() })
        var receivedResults = [Error?]()

        sut?.save(feed: [anyFeeditem().model]) { error in
            receivedResults.append(error)
        }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }

    // Helpers

    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (localFeeedLoader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let localFeedLoader = LocalFeedLoader(store: store, timestamp: timestamp)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(localFeedLoader)
        return (localFeedLoader, store)
    }

    private func anyFeeditem() -> (model: FeedItem, local: LocalFeedItem) {
        let feedItem = FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
        let local: LocalFeedItem = LocalFeedItem(id: feedItem.id, description: feedItem.description, location: feedItem.location, imageURL: feedItem.imageURL)
        return (feedItem, local)
    }

    private func anyURL() -> URL {
        return URL(string: "https://test-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

}
