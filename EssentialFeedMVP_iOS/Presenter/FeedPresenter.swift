//
//  FeedPresenter.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import EssentialFeed
import Foundation

final class FeedPresenter {

    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView

    private let feedErrorView: FeedErrorView

    static let title = NSLocalizedString("FEED_VIEW_TITLE",
                                         tableName: "Feed",
                                         bundle: Bundle(for: FeedPresenter.self),
                                         comment: "Title for the feed view")
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    init(feedView: FeedView, feedLoadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
        self.feedErrorView = feedErrorView
    }

    func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedItem]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingWithError(with error: Error) {
        feedErrorView.display(.error(message: feedLoadError))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
