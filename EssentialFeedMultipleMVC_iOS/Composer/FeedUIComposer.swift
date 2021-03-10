//
//  FeedUIComposer.swift
//  EssentialFeedMultipleMVC_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-03.
//

import EssentialFeed

public final class FeedUIComposer {

    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(feedRefreshController: feedRefreshController)
        feedRefreshController.onRefresh = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
        return feedViewController
    }

}
