//
//  FeedLoadingView.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}
