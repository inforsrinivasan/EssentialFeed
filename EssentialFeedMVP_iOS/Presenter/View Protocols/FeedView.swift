//
//  FeedView.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

import EssentialFeed

struct FeedViewModel {
    let feed: [FeedItem]
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}
