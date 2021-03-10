//
//  FeedRefreshViewController.swift
//  EssentialFeedMVVM_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-06.
//

import UIKit

public final class FeedRefreshViewController: NSObject {

    private var viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    private(set) lazy var refreshView: UIRefreshControl = binded(UIRefreshControl())

    @objc
    func refresh() {
        viewModel.loadFeed()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        // Binds the view to the ViewModel
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        // Binds the ViewModel to the View
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

