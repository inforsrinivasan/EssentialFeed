//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Srinivasan Rajendran on 2021-03-29.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()

        let sut = makeSUT(primaryResult: .success(primaryFeed),
                          fallbackResult: .success(fallbackFeed))
        expect(sut: sut, toCompleteWith: .success(primaryFeed))
    }

    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()

        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        expect(sut: sut, toCompleteWith: .success(fallbackFeed))
    }

    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        expect(sut: sut, toCompleteWith: .failure(anyNSError()))
    }

    func expect(sut: FeedLoader,
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

    // helpers

    private func makeSUT(primaryResult: LoadFeedResult,
                         fallbackResult: LoadFeedResult,
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
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

}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak. Instance should have been deallocated", file: file, line: line)
        }
    }
}
