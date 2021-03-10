//
//  FeedItemCell.swift
//  EssentialFeed_iOS
//
//  Created by Srinivasan Rajendran on 2021-02-24.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc
    private func retryButtonTapped() {
        onRetry?()
    }
}
