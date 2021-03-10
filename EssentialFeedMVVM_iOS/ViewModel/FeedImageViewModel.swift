//
//  FeedImageViewModel.swift
//  EssentialFeedMVVM_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-06.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {

    typealias Observer<T> = (T) -> Void

    private var task: FeedImageDataLoaderTask?
    private let model: FeedItem
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?

    var hasLocation: Bool {
        return model.location != nil
    }

    var location: String? {
        return model.location
    }

    var description: String? {
        return model.description
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    init(model: FeedItem,
         imageLoader: FeedImageDataLoader,
         imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            guard let self = self else { return }
            if let image = (try? result.get()).flatMap(self.imageTransformer) {
                self.onImageLoad?(image)
            } else {
                self.onShouldRetryImageLoadStateChange?(true)
            }
            self.onImageLoadingStateChange?(false)
        }
    }

    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }

    func cancelLoad() {
        task?.cancel()
    }
}
