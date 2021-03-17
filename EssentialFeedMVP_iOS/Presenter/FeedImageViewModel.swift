//
//  FeedImageViewModel.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
