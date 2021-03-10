//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-01-31.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "https://tesat.com")!
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
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
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private class URLProtocolStub: URLProtocol {

        private static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?

        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }

        static func observeRequests(completion: @escaping (URLRequest) -> Void) {
            observer = completion
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            observer = nil 
            stub = nil
        }

        class func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(error: error, data: data, response: response)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            observer?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

    }

}
