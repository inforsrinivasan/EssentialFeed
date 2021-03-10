//
//  FeedRefreshViewController.swift
//  EssentialFeedMultipleMVC_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-03.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {

    private var feedLoader: FeedLoader

    var  onRefresh: (([FeedItem]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    private(set) lazy var refreshView: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    @objc
    func refresh() {
        refreshView.beginRefreshing()
        feedLoader.loadFeed { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.refreshView.endRefreshing()
        }
    }
}
