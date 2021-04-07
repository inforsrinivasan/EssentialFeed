//
//  SceneDelegatetests.swift
//  EssentialAppTests
//
//  Created by Srinivasan Rajendran on 2021-04-07.
//

import XCTest
import EssentialFeedMVP_iOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller")
    }
}
