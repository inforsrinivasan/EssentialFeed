//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-17.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    public var hasLocation: Bool {
        return location != nil
    }
}

public protocol FeedImageView {
    associatedtype Image

    func display(_ viewModel: FeedImageViewModel<Image>)
}
