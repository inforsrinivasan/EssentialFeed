//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }

    func test_didStartLoadingFeed_displaysNoErrorMessage_andStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
                                       .display(isLoading: true)])
    }

    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = anyFeeditem()

        sut.didFinishLoadingFeed(with: [feed])
        XCTAssertEqual(view.messages, [.display(feed: [feed]),
                                       .display(isLoading: false)])
    }

    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingWithError(with: anyNSError())
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
                                       .display(isLoading: false)])
    }

    // helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, feedLoadingView: view, feedErrorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private func anyFeeditem() -> FeedItem {
        let feedItem = FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
        return feedItem
    }

    private func anyURL() -> URL {
        return URL(string: "https://test-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 1, userInfo: nil)
    }

    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if key == value {
            XCTFail("Missing localized string for key \(key) in file \(table)")
        }
        return value
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {

        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedItem])
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }

        func display(viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(viewModel: FeedViewModel) {
            messages.append(.display(feed: viewModel.feed))
        }
    }
}
