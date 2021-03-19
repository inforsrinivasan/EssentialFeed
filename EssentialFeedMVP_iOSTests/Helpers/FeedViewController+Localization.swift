//
//  FeedViewController+Localization.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-11.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if key == value {
            XCTFail("Missing localized string for key \(key) in file \(table)")
        }
        return value
    }
}
