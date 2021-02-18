//
//  CodableFeedStoreTest.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-02-15.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for expectation")
        sut.loadFeed { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for expectation")
        sut.loadFeed { firstResult in
            sut.loadFeed { secondResult in
                switch (firstResult, secondResult) {
                    case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty and empty for both cases")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let localFeedItem = anyFeeditem().local
        let timestamp = Date()
        let exp = expectation(description: "wait for expectation")
        sut.insertFeed(feed: [localFeedItem], timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected insertion to be success")
            sut.loadFeed { result in
                switch result {
                case .found(feed: let receivedFeed, timestamp: let receivedtimestamp):
                    XCTAssertEqual(receivedFeed, [localFeedItem])
                    XCTAssertEqual(receivedtimestamp, timestamp)
                default:
                    XCTFail("Expected to be found a valid cache")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveDeliversFailureOnRetrievalError() {
        let storeURL = testStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        var receivedError: Error?
        let exp = expectation(description: "wait for expectation")
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        sut.loadFeed { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected error but received \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        let expFirst = expectation(description: "wait for expectation")
        let firstFeed = anyFeeditem()
        let firstFeedTimestamp = Date()
        sut.insertFeed(feed: [firstFeed.local], timestamp: firstFeedTimestamp) { error in
            expFirst.fulfill()
        }
        wait(for: [expFirst], timeout: 1.0)

        let expSecond = expectation(description: "wait for expectation")
        let secondFeed = anyFeeditem()
        let secondFeedTimestamp = Date()
        sut.insertFeed(feed: [secondFeed.local], timestamp: secondFeedTimestamp) { error in
            expSecond.fulfill()
        }
        wait(for: [expSecond], timeout: 1.0)

        let expThird = expectation(description: "wait for expectation")
        sut.loadFeed { result in
            switch result {
            case .found(feed: let feed, timestamp: let time):
                XCTAssertEqual(feed, [secondFeed.local])
                XCTAssertEqual(time, secondFeedTimestamp)
            default:
                XCTFail("Expected found but received \(result)")
            }
            expThird.fulfill()
        }
        wait(for: [expThird], timeout: 1.0)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://url-for-testing")!
        let sut = makeSUT(storeURL: invalidURL)
        let exp = expectation(description: "wait for expectation")
        sut.insertFeed(feed: [anyFeeditem().local], timestamp: Date()) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for expectation")
        sut.deleteCachedFeed { error in
            XCTAssertNil(error, "Expected empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        let expRetrieve = expectation(description: "wait for retrieve exp")
        sut.loadFeed { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, but found \(result)")
            }
            expRetrieve.fulfill()
        }
        wait(for: [expRetrieve], timeout: 1.0)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        let expFirst = expectation(description: "wait for expectation")
        let firstFeed = anyFeeditem()
        let firstFeedTimestamp = Date()
        sut.insertFeed(feed: [firstFeed.local], timestamp: firstFeedTimestamp) { error in
            expFirst.fulfill()
        }
        wait(for: [expFirst], timeout: 1.0)

        let exp = expectation(description: "wait for delete expectation")
        sut.deleteCachedFeed { error in
            XCTAssertNil(error, "Expected empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        let expRetrieve = expectation(description: "wait for retrieve exp")
        sut.loadFeed { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, but found \(result)")
            }
            expRetrieve.fulfill()
        }
        wait(for: [expRetrieve], timeout: 1.0)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let exp = expectation(description: "wait for exp")
        sut.deleteCachedFeed { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "wait for expectation")
        sut.insertFeed(feed: [anyFeeditem().local], timestamp: Date()) { error in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "wait for expectation")
        sut.deleteCachedFeed { error in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "wait for expectation")
        sut.insertFeed(feed: [anyFeeditem().local], timestamp: Date()) { error in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side effects to run serially, but finished in wrong order")
    }

    // Helpers

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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

    private func testStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func setUpEmptyStoreState() {
        deleteStoreArtificats()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtificats()
    }

    private func deleteStoreArtificats() {
        try? FileManager.default.removeItem(at: testStoreURL())
    }

}
