//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-01-31.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "https://tesat.com")!
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(url: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let sut = makeSUT()
        let url = URL(string: "https://tesat.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        let exp = expectation(description: "wait for completion")
        sut.get(url: url) { receivedResult in
            switch receivedResult {
            case .failure(let receivedError):
                XCTAssertEqual((receivedError as NSError?)?.code, error.code)
                XCTAssertEqual((receivedError as NSError?)?.domain, error.domain)
            default:
                XCTFail("expected to fail")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        let anyNonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 2, textEncodingName: nil)
        let anyHTTPURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let anyData = Data("some data".utf8)
        let anyError = NSError(domain: "test", code: 1, userInfo: nil)

        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyNonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyNonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyNonHTTPURLResponse, error: nil))
    }

    func test_getFromURL_deliversSuccessfulDataAndResponse() {
        let anyData = Data("some data".utf8)
        let anyHTTPURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)
        let sut = makeSUT()
        let exp = expectation(description: "wait for expectation")
        sut.get(url: anyURL()) { result in
            switch result {
            case .success(let data, let response):
                XCTAssertEqual(anyData, data)
                XCTAssertEqual(anyHTTPURLResponse?.url, response.url)
                XCTAssertEqual(anyHTTPURLResponse?.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let url = anyURL()
        let sut = makeSUT()

        let exp = expectation(description: "Wait for request")
        let task = sut.get(url: url) { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                break
            default:
                XCTFail("Expected cancelled result, but got \(result) instead")
            }
            exp.fulfill()
        }
        task.cancel()
        wait(for: [exp], timeout: 1.0)
    }

    // Helpers

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        var receivedError: Error?
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for expectation")
        sut.get(url: anyURL()) { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Received failure but got success", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedError
    }

    private func anyURL() -> URL {
        return URL(string: "https://tesat.com")!
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}
