//
//  FeedViewControllerTests.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialApp
import EssentialFeedMVP_iOS

final class FeedViewControllerTests: XCTestCase {

    func test_feedView_hasTitle() {
        let (sut,_) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.title)
    }

    func test_feedView_hasLocalizedTitle() {
        let (sut,_) = makeSUT()
        sut.loadViewIfNeeded()
        let localizedKey = "FEED_VIEW_TITLE"
        XCTAssertEqual(sut.title, localized(localizedKey))
    }

    func test_loadFeedActions_requestsFeedFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()

        let feed0 = makeFeed(description: "desc0", location: "loca0")

        loader.completeFeedLoading(with: [feed0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedItems(), 1)
        assertThat(sut, hasViewConfiguredFor: feed0, at: 0)

        let feed1 = makeFeed(description: "desc1", location: "loca1")
        let feed2 = makeFeed(description: nil, location: nil)
        let feed3 = makeFeed(description: "desc3", location: "loca3")

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [feed0, feed1, feed2, feed3], at: 1)
        XCTAssertEqual(sut.numberOfRenderedItems(), 4)
        assertThat(sut, hasViewConfiguredFor: feed0, at: 0)
        assertThat(sut, hasViewConfiguredFor: feed1, at: 1)
        assertThat(sut, hasViewConfiguredFor: feed2, at: 2)
        assertThat(sut, hasViewConfiguredFor: feed3, at: 3)
    }

    func test_loadFeedCompletion_rendersPreviouslyRenderedFeedWhenReceivedError() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()

        let feed0 = makeFeed(description: "desc0", location: "loca0")

        loader.completeFeedLoading(with: [feed0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedItems(), 1)
        assertThat(sut, hasViewConfiguredFor: feed0, at: 0)

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, hasViewConfiguredFor: feed0, at: 0)
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL], "Expected first image url request when first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL], "Expected first image url request when first view becomes visible")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image url requests until views become visible")

        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [feed1.imageURL], "Expected first image url cancelled request")
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [feed1.imageURL, feed2.imageURL], "Expected first and second image url cancelled request")
    }

    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)

        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }

    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)

        let view0  = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.renderedImageData, .none, "Image should not have been rendered")
        XCTAssertEqual(view1?.renderedImageData, .none, "Image should not have been rendered")

        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image0Data, at: 0)

        XCTAssertEqual(view0?.renderedImageData, image0Data, "Image0 should have been rendered")
        XCTAssertEqual(view1?.renderedImageData, .none, "Image should not have been rendered")

        let image1Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image1Data, at: 1)

        XCTAssertEqual(view0?.renderedImageData, image0Data, "Image0 should have been rendered")
        XCTAssertEqual(view1?.renderedImageData, image1Data, "Image1 should have been rendered")
    }

    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.isRetryVisible, false)
        XCTAssertEqual(view0?.isRetryVisible, false)

        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image0Data, at: 0)
        XCTAssertEqual(view0?.isRetryVisible, false)

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isRetryVisible, true)
    }

    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)

        XCTAssertEqual(view0?.isRetryVisible, false)
        XCTAssertEqual(view0?.isRetryVisible, false)

        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image0Data, at: 0)
        XCTAssertEqual(view0?.isRetryVisible, false)

        let invalidImgaeData = Data("invalid data".utf8)
        loader.completeImageLoading(with: invalidImgaeData, at: 1)
        XCTAssertEqual(view1?.isRetryVisible, true)
    }

    func test_feedImageViewRetryAction_retriesImageLoad() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL], "expected two image url requests for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL], "Expected only two image urls before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL, feed1.imageURL], "Expected third image url request after first view retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL, feed1.imageURL, feed2.imageURL], "Expected third and fourth image url request after first and second view retry action")
    }

    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "expected no image URL requests until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL], "expected first image URL request when image view is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [feed1.imageURL, feed2.imageURL], "expected first and second image URL request when image view is near visible")
    }

    func test_feedImageView_cancelsImageURLpreloadingWhenNotNearVisibleAnymore() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let feed2 = makeFeed(url: URL(string: "feed2-url")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1, feed2], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "expected no cancelled image url requests until image is not near visible")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [feed1.imageURL], "expected first cancelled image url request once first view is not near visible anymore")
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [feed1.imageURL, feed2.imageURL], "expected first and second cancelled image url request once first and second view is not near visible anymore")
    }

    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        let test1ImageData = UIImage.make(withColor: .red).pngData()!

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1], at: 0) // feed

        let view = sut.simulateFeedImageViewNotVisible(at: 0) // images after feed
        loader.completeImageLoading(with: test1ImageData, at: 0)

        XCTAssertNil(view.renderedImageData, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        sut.loadViewIfNeeded()

        let exp = expectation(description: "wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(with: [feed1], at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut,loader) = makeSUT()
        let feed1 = makeFeed(url: URL(string: "feed1-url")!)
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [feed1], at: 0)

        _ = sut.simulateFeedImageViewVisible(at: 0)
        let exp = expectation(description: "wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: UIImage.make(withColor: .red).pngData()!, at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_loadFeedCompletion_rendersErrorMessageOnErroruntilNextReload() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, localized("FEED_VIEW_CONNECTION_ERROR"))
    }

    // Helpers

    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor item: FeedItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedItemView(at: index)

        guard let cell = view as? FeedItemCell else {
            return XCTFail("Expected FeedItemCell, but expected \(type(of: view))")
        }
        XCTAssertEqual(cell.descriptionText, item.description)
        XCTAssertEqual(cell.locationText, item.location)
        XCTAssertEqual(cell.isShowingLocation, item.location != nil)
    }

    private func makeFeed(description: String? = nil,
                          location: String? = nil,
                          url: URL = URL(string: "test-url")!) -> FeedItem {
        return FeedItem(id: UUID(), description: description, location: location, imageURL: url)
    }

    private func makeSUT() -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
}

private class LoaderSpy: FeedLoader, FeedImageDataLoader {

    var loadFeedCallCount: Int {
        return feedRequests.count
    }

    private var feedRequests = [(LoadFeedResult) -> Void]()

    func loadFeed(completion: @escaping (LoadFeedResult) -> Void) {
        feedRequests.append(completion)
    }

    func completeFeedLoading(with feed: [FeedItem] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        imageRequests[index].completion(.failure(error))
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        feedRequests[index](.failure(error))
    }

    // Image Loader

    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }

    private(set) var imageRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs: [URL] = []

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
}
