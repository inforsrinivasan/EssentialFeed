//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-01-24.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.loadFeed() { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.loadFeed() { _ in }
        sut.loadFeed() { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut: sut, loadWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, status in
            expect(sut: sut, loadWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                let validJsonData = makeItemsJsonData(items: [])
                client.complete(status: status, data: validJsonData, at: index)
            }
        }
    }

    func test_load_deliversInvalidDataErrorOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        expect(sut: sut, loadWith: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data(bytes: "invalid", count: 1)
            client.complete(status: 200, data: invalidJSON)
        }
    }

    func test_load_deliversEmptyFeedOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        expect(sut: sut, loadWith: .success([])) {
            let emptyJSONdata = makeItemsJsonData(items: [])
            client.complete(status: 200, data: emptyJSONdata)
        }
    }

    func test_load_deliversFeedItemsOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let feedItem1 = anyFeeditem()
        let feedItem2 = anyFeeditem()

        expect(sut: sut, loadWith: .success([feedItem1.item, feedItem2.item])) {
            let jsonData = makeItemsJsonData(items: [feedItem1.json, feedItem2.json])
            client.complete(status: 200, data: jsonData)
        }
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: anyURL(), client: client)

        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.loadFeed { capturedResults.append($0) }

        sut = nil

        client.complete(status: 200, data: makeItemsJsonData(items: [anyFeeditem().json,
                                                                     anyFeeditem().json]))
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // Helpers

    private func expect(sut: RemoteFeedLoader, loadWith expectedResult: RemoteFeedLoader.Result, action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "wait for load completion")
        sut.loadFeed { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected \(expectedResult) but received \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func anyFeeditem() -> (item: FeedItem, json: [String: String?]) {
        let feedItem = FeedItem(id: UUID(), description: "description", location: "location", imageURL: anyURL())
        let feedItemjson = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageURL.absoluteString
        ]
        return (feedItem, feedItemjson)
    }

    private func makeItemsJsonData(items: [[String: String?]]) -> Data {
        let jsonObject = [
            "items": items
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        return jsonData
    }

    private func makeSUT(url: URL = URL(string: "https://test-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func anyURL() -> URL {
        return URL(string: "https://test-url.com")!
    }

    private class HTTPClientSpy: HTTPClient {

        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(status: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: status, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
