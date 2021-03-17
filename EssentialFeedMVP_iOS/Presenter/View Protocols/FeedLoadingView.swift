//
//  FeedLoadingView.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//


struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}
