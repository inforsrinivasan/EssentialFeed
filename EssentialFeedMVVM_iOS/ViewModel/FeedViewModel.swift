//
//  FeedViewModel.swift
//  EssentialFeedMVVM_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-06.
//

import EssentialFeed

final class FeedViewModel {

    typealias Observer<T> = (T) -> Void

    private enum State {
        case pending
        case loading
    }

    private var feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedItem]>?



    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.loadFeed { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
