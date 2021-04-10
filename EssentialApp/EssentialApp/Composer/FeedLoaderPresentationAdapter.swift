//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-14.
//

import EssentialFeed
import EssentialFeedMVP_iOS

internal final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {

    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.loadFeed { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingWithError(with: error)
            }
        }
    }
}
