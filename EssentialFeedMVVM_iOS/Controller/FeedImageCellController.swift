//
//  FeedImageCellController.swift
//  EssentialFeedMVVM_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-06.
//

import UIKit

public final class FeedImageCellController {

    private let viewModel: FeedImageViewModel<UIImage>

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedItemCell())
        viewModel.loadImageData()
        return cell
    }

    private func binded(_ cell: FeedItemCell) -> FeedItemCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.retryButton.isHidden = true
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }

        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }

        return cell
    }

    func preload() {
        viewModel.preload()
    }

    func cancelLoad() {
        viewModel.cancelLoad()
    }
}

