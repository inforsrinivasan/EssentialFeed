//
//  FeedViewController+TestHelper.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-11.
//

import UIKit
import EssentialFeedMVP_iOS

extension FeedViewController {

    var errorMessage: String? {
        return errorView?.message
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    private var feedSection: Int {
        return 0
    }

    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedItemCell? {
        return feedItemView(at: index) as? FeedItemCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedItemCell {
        let cell = simulateFeedImageViewVisible(at: row)!
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: index)
        return cell
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }

    func numberOfRenderedItems() -> Int {
        return tableView.numberOfRows(inSection: feedSection)
    }

    func feedItemView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
