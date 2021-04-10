//
//  FeedImageDataPresentationAdapter.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-14.
//

import Foundation
import EssentialFeed
import EssentialFeedMVP_iOS

internal final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {

    private let model: FeedItem
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedItem, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
