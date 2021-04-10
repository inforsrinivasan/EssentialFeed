//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Srinivasan Rajendran on 2021-04-07.
//

import XCTest
import EssentialFeed
import EssentialFeedMVP_iOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)

        XCTAssertEqual(feed.numberOfRenderedItems(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)

        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedItems(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)

        XCTAssertEqual(feed.numberOfRenderedItems(), 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache

        enterBackground(with: store)
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        enterBackground(with: store)
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline,
                        store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }

    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline,
                                store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }

    private class HTTPClientStub: HTTPClient {

        private class Task: HTTPClientTask {
            func cancel() {}
        }

        private let stub: (URL) -> HTTPClientResult

        init(stub: @escaping (URL) -> HTTPClientResult) {
            self.stub = stub
        }

        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url).0, stub(url).1) }
        }
    }

    private class InMemoryFeedStore: FeedImageDataStore, FeedStore {

        private var feedImageDataCache: [URL: Data] = [:]
        private(set) var feedCache: (feed: [LocalFeedItem], timestamp: Date)?

        init(feedCache: (feed: [LocalFeedItem], timestamp: Date)? = nil) {
            self.feedCache = feedCache
        }

        // MARK: - Feed Image Data Store

        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }

        // MARK: - Feed Store

        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(nil)
        }

        func insertFeed(feed: [LocalFeedItem],
                        timestamp: Date,
                        completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = (feed, timestamp)
            completion(nil)
        }

        func loadFeed(completion: @escaping FeedStore.RetrievalCompletion) {
            if let feedCache = feedCache {
                completion(.found(feed: feedCache.feed, timestamp: feedCache.timestamp))
            } else {
                completion(.empty)
            }
        }

        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }

        static var withExpiredFeedCache: InMemoryFeedStore {
            let emptyFeed = [LocalFeedItem]()
            return InMemoryFeedStore(feedCache: (emptyFeed, Date().expired()))
        }

        static var withNonExpiredFeedCache: InMemoryFeedStore {
            let emptyFeed = [LocalFeedItem]()
            return InMemoryFeedStore(feedCache: (emptyFeed, Date()))
        }
        
    }

}

private extension Date {
    func expired() -> Self {
        return Calendar.init(identifier: .gregorian).date(byAdding: .day, value: -7, to: self)!
    }
}
