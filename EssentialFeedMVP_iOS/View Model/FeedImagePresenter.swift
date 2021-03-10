//
//  FeedImagePresenter.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-09.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedItem) {
        view.display(FeedImageViewModel(description: model.description,
                                        location: model.location,
                                        image: nil,
                                        isLoading: true,
                                        shouldRetry: false))
    }

    func didFinishLoadingImageData(with data: Data, for model: FeedItem) {
        guard let image = imageTransformer(data) else  {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view.display(FeedImageViewModel(description: model.description,
                                        location: model.location,
                                        image: image,
                                        isLoading: false,
                                        shouldRetry: false))
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImageData(with error: Error, for model: FeedItem) {
        view.display(FeedImageViewModel(description: model.description,
                                        location: model.location,
                                        image: nil,
                                        isLoading: false,
                                        shouldRetry: true))
    }
}
