//
//  FeedUIComposer.swift
//  EssentialFeedMVVM_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-06.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {

    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(feedRefreshController: feedRefreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedViewController,
                                                              loader: imageLoader)
        return feedViewController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController,
                                                   loader: FeedImageDataLoader) -> ([FeedItem]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { feedItem in
                let feedImageViewModel = FeedImageViewModel(model: feedItem,
                                                            imageLoader: loader,
                                                            imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: feedImageViewModel)
            }
        }
    }
}
