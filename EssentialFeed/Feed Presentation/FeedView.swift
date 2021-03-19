//
//  FeedView.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

public struct FeedViewModel {
    public let feed: [FeedItem]
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
