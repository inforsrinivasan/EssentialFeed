//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }

}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
