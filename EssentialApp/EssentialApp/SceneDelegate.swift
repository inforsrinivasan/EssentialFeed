//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Srinivasan Rajendran on 2021-03-27.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeedMVP_iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, timestamp: Date.init)
    }()

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer
                                .defaultDirectoryURL()
                                .appendingPathComponent("feed-store.sqlite"))
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    func configureWindow() {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!

        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        let feedViewController = FeedUIComposer
            .feedComposedWith(
                feedLoader: FeedLoaderWithFallbackComposite(
                    primary: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader),
                    fallback: localFeedLoader),
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader)
                )
            )

        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache()
    }
}
