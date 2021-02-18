//
//  LoadFeedFromCacheUseCaseTesats.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-02-10.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotRequestLoadUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_loadFeed_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.loadFeed() { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_loadFeed_failsOnCacheRetrieval() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        var receivedError: Error?

        let exp = expectation(description: "wait for completion")
        sut.loadFeed { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, but received \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: error)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, error)
    }

    func test_loadFeed_deliversNoFeedOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedFeed: [FeedItem]?
        let exp = expectation(description: "wait for completion")
        sut.loadFeed { result in
            switch result {
            case .success(let feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success, but received \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, [])
    }

    func test_loadFeed_deliversFeedOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        var receivedFeed: [FeedItem]?
        let feed = anyFeeditem()
        let exp = expectation(description: "wait for completion")
        sut.loadFeed { result in
            switch result {
            case .success(let feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success, but received \(result) instead")
            }
            exp.fulfill()
        }
        let lessThanSevenDays = Date().adding(days: -7).adding(seconds: 2)
        store.completeRetrieval(with: [feed.local], timestamp: lessThanSevenDays)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, [feed.model])
    }

    func test_loadFeed_deliversEmptyFeedOnSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedCurrentDate })
        var receivedFeed: [FeedItem]?
        let feed = anyFeeditem()
        let exp = expectation(description: "wait for completion")
        sut.loadFeed { result in
            switch result {
            case .success(let feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success, but received \(result) instead")
            }
            exp.fulfill()
        }
        let sevenDays = fixedCurrentDate.adding(days: -7)
        store.completeRetrieval(with: [feed.local], timestamp: sevenDays)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, [])
    }

    func test_loadFeed_deliversEmptyFeedOnMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedCurrentDate })
        var receivedFeed: [FeedItem]?
        let feed = anyFeeditem()
        let exp = expectation(description: "wait for completion")
        sut.loadFeed { result in
            switch result {
            case .success(let feed):
                receivedFeed = feed
            default:
                XCTFail("Expected success, but received \(result) instead")
            }
            exp.fulfill()
        }
        let moreThanSevenDays = fixedCurrentDate.adding(days: -7).adding(seconds: -2)
        store.completeRetrieval(with: [feed.local], timestamp: moreThanSevenDays)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedFeed, [])
    }

    func test_loadFeed_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.loadFeed() { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_loadFeed_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.loadFeed() { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_loadFeed_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = anyFeeditem()

        sut.loadFeed() { _ in }
        let lessThanSevenDays = Date().adding(days: -7).adding(seconds: 2)
        store.completeRetrieval(with: [feed.local], timestamp: lessThanSevenDays)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_loadFeed_hasNoSideEffectsOnSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = anyFeeditem()

        sut.loadFeed() { _ in }
        let sevenDays = Date().adding(days: -7)
        store.completeRetrieval(with: [feed.local], timestamp: sevenDays)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_loadFeed_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.loadFeed { receivedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
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

    private func anyFeeditem() -> (local: LocalFeedItem, model: FeedItem) {
        let feedItem = FeedItem(id: UUID(), description: "any desc", location: "any loc", imageURL: anyURL())
        let localItem = LocalFeedItem(id: feedItem.id, description: feedItem.description, location: feedItem.location, imageURL: feedItem.imageURL)
        return (localItem, feedItem)
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
