//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

import Foundation

public final class FeedPresenter {
    private let feedErrorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView

    public init(feedView: FeedView, feedLoadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }

    public static var title: String { return NSLocalizedString("FEED_VIEW_TITLE",
                                                        tableName: "Feed",
                                                        bundle: Bundle(for: FeedPresenter.self),
                                                        comment: "Title for the feed view")
    }

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    public func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedItem]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingWithError(with error: Error) {
        feedErrorView.display(.error(message: feedLoadError))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
