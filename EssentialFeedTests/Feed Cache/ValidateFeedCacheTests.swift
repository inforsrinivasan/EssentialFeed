//
//  ValidateFeedCacheTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-02-13.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = anyFeeditem()

        sut.validateCache()
        let lessThanSevenDays = Date().adding(days: -7).adding(seconds: 2)
        store.completeRetrieval(with: [feed.local], timestamp: lessThanSevenDays)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesCacheOnSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = anyFeeditem()

        sut.validateCache()
        let sevenDays = Date().adding(days: -7)
        store.completeRetrieval(with: [feed.local], timestamp: sevenDays)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteInvalisCacheAfterSUTInstanceHAsBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)

        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    private func anyFeeditem() -> (local: LocalFeedItem, model: FeedItem) {
        let feedItem = FeedItem(id: UUID(), description: "any desc", location: "any loc", imageURL: anyURL())
        let localItem = LocalFeedItem(id: feedItem.id, description: feedItem.description, location: feedItem.location, imageURL: feedItem.imageURL)
        return (localItem, feedItem)
    }

    // Helpers

    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (localFeeedLoader: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let localFeedLoader = LocalFeedLoader(store: store, timestamp: timestamp)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(localFeedLoader)
        return (localFeedLoader, store)
    }

    private func anyURL() -> URL {
        return URL(string: "https://test-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

}

private extension Date {
    func adding(days: Int) -> Self {
        return Calendar.init(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Self {
        return self + seconds
    }
}
