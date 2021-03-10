//
//  FeedPresenter.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedItem]
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {

    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView

    init(feedView: FeedView, feedLoadingView: FeedLoadingView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }

    func didStartLoadingFeed() {
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedItem]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingWithError(with error: Error) {
        feedLoadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
