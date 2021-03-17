//
//  FeedUIComposer.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {

    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {

        let feedPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))

        let feedViewController = makeFeedViewController(delegate: feedPresentationAdapter,
                                                        title: FeedPresenter.title)

        let feedPresenter = FeedPresenter(feedView: FeedViewAdapter(
                                            controller: feedViewController,
                                            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
                                          feedLoadingView: WeakRefVirtualProxy(feedViewController), feedErrorView: WeakRefVirtualProxy(feedViewController))

        feedPresentationAdapter.presenter = feedPresenter
        return feedViewController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerDelegate,
                                        title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)

        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = FeedPresenter.title
        return feedViewController
    }
}
