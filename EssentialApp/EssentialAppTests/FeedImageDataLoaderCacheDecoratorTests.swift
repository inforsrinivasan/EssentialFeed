//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Srinivasan Rajendran on 2021-04-01.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
    }

    func test_loadImageData_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from loader")
    }

    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL from loader")
    }

    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let imageData = anyData()
        expect(sut, toCompleteWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
    }

    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompleteWith: .failure(error)) {
            loader.complete(with: error)
        }
    }

    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let cache = CacheSpy()
        let url = anyURL()
        let imageData = anyData()
        let (sut, loader) = makeSUT(cache: cache)
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: imageData)
        XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)], "Expected to cache loaded image data on success")
    }

    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let cache = CacheSpy()
        let url = anyURL()
        let dataError = anyNSError()
        let (sut, loader) = makeSUT(cache: cache)
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: dataError)
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache image data on loader error")
    }

    // helpers

    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)

            case (.failure, .failure):
                break

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(cache: CacheSpy = CacheSpy(),
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: FeedImageDataLoader,
                                                 loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func uniqueFeed() -> [FeedItem] {
        return [FeedItem(id: UUID(), description: "dec", location: "loc", imageURL: anyURL())]
    }

    private func anyData() -> Data {
        return Data("any-Data".utf8)
    }

    private func anyURL() -> URL {
        return URL(string: "http://test-url")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

    private class LoaderSpy: FeedImageDataLoader {

        private var messages: [(url: URL, completion:  (FeedImageDataLoader.Result) -> Void)] = []

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        private(set) var cancelledURLs: [URL] = []

        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func complete(with imageData: Data, at index: Int = 0) {
            messages[index].completion(.success(imageData))
        }

        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }

    private class CacheSpy: FeedImageDataCache {

        private(set) var messages: [Message] = []

        enum Message: Equatable {
            case save(data: Data, for: URL)
        }

        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data: data, for: url))
        }
    }
}
