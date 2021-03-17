//
//  FeedImageCell.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-08.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
