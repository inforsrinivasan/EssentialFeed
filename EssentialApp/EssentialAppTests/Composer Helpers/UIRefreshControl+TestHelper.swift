//
//  UIRefreshControl+TestHelper.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-11.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        }
    }
}
