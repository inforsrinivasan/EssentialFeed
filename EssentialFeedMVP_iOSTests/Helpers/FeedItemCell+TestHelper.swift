//
//  FeedItemCell+TestHelper.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-11.
//

import Foundation
import EssentialFeedMVP_iOS

extension FeedItemCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var isShowingLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }

    var renderedImageData: Data? {
        return feedImageView.image?.pngData()
    }

    var isRetryVisible: Bool {
        return !retryButton.isHidden
    }

    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}
