//
//  FeedRefreshViewController.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {

    var delegate: FeedRefreshViewControllerDelegate

    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }

    private(set) lazy var refreshView: UIRefreshControl = loadView()

    @objc
    func refresh() {
        delegate.didRequestFeedRefresh()
    }

    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshView.beginRefreshing()
        } else {
            refreshView.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
