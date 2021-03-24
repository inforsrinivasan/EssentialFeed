//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-03-24.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {

    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
        completion(.success(.none))
    }

}

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!

       // sut.insert(anyData(), for: url, completion: <#T##(Result<Void, Error>) -> Void#>)

        expect(sut, toCompleteRetrievalWith: .success(.none), for: nonMatchingURL)
    }

    // helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetreivalResult {
        return .success(.none)
    }

    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetreivalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

//    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
//        let exp = expectation(description: "Wait for cache insertion")
//        let image = localImage(url: url)
//        sut.insertFeed(feed: [image], timestamp: Date()) { result in
//            switch result {
//            case let .failure(error):
//                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
//
//            case .success:
//                sut.insert(data, for: url) { result in
//                    if case let Result.failure(error) = result {
//                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
//                    }
//                }
//            }
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 1.0)
//    }

    private func localImage(url: URL) -> LocalFeedItem {
        return LocalFeedItem(id: UUID(), description: "any", location: "any", imageURL: url)
    }

    private func anyURL() -> URL {
        return URL(string: "https://test-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

    private func anyData() -> Data {
        return Data("any data".utf8)
    }
}
