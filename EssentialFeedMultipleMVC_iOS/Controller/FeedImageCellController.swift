//
//  FeedImageCellController.swift
//  EssentialFeedMultipleMVC_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-03.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController {

    private var task: FeedImageDataLoaderTask?
    private let model: FeedItem
    private let imageLoader: FeedImageDataLoader

    init(model: FeedItem, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()
        return cell
    }

    func preload() {
        self.task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }

    func cancelLoad() {
        task?.cancel()
    }
}
