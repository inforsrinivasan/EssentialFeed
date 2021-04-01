//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Srinivasan Rajendran on 2021-04-01.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        expect(sut: sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let feedError = anyNSError()
        let sut = makeSUT(loaderResult: .failure(feedError))
        expect(sut: sut, toCompleteWith: .failure(feedError))
    }

    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        sut.loadFeed { _ in }
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected feed to be cached on load success")
    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let feedError = anyNSError()
        let sut = makeSUT(loaderResult: .failure(feedError), cache: cache)
        sut.loadFeed { _ in }
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
    }

    // helpers

    private func expect(sut: FeedLoader,
                toCompleteWith expectedResult: LoadFeedResult,
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "wait for feed")
        sut.loadFeed { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead",
                        file: file,
                        line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(loaderResult: LoadFeedResult,
                         cache: FeedCache = CacheSpy(),
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoader {
        let loader = LoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }

    private func uniqueFeed() -> [FeedItem] {
        return [FeedItem(id: UUID(), description: "dec", location: "loc", imageURL: anyURL())]
    }

    private func anyURL() -> URL {
        return URL(string: "http://test-url")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

    private class LoaderStub: FeedLoader {

        private let result: LoadFeedResult

        init(result: LoadFeedResult) {
            self.result = result
        }

        func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
            completion(result)
        }
    }

    private class CacheSpy: FeedCache {

        var messages = [Message]()

        enum Message: Equatable {
            case save([FeedItem])
        }

        func save(feed: [FeedItem], completion: @escaping (Error?) -> Void) {
            messages.append(.save(feed))
            completion(.none)
        }
    }

}
