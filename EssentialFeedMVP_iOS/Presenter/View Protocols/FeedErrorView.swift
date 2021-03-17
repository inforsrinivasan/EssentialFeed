//
//  FeedErrorView.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
