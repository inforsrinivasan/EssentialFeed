//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Srinivasan Rajendran on 2021-02-18.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {


    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for expectation")
        sut.loadFeed { result in
            switch result {
            case .success(let items):
                XCTAssertTrue(items.isEmpty)
            default:
                XCTFail("Expected empty, but found \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversitemsSavedOnASeperateInstance() {
        let sutInstance1 = makeSUT()
        let sutInstance2 = makeSUT()
        let feedItem = anyFeeditem()

        let saveExp = expectation(description: "wait for expectation")
        sutInstance1.save(feed: [feedItem.model]) { error in
            XCTAssertNil(error, "Expected to save successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)

        let loadExp = expectation(description: "wait for expectation")
        sutInstance2.loadFeed { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual([feedItem.model], feed)
            default:
                XCTFail("Expected to receive equal feed, but received \(result)")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }

    // Helpers

    private func makeSUT() -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let coreDataStore = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let localFeedLoader = LocalFeedLoader(store: coreDataStore, timestamp: Date.init)
        trackForMemoryLeaks(coreDataStore)
        trackForMemoryLeaks(localFeedLoader)
        return localFeedLoader
    }

    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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

    private func setUpEmptyStoreState() {
        deleteStoreArtificats()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtificats()
    }

    private func deleteStoreArtificats() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
