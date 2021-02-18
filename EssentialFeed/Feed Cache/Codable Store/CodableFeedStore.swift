//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-16.
//
import Foundation

public class CodableFeedStore: FeedStore {

    private struct Cache: Codable {
        let feed: [CodableFeedItem]
        let timestamp: Date
    }

    private struct CodableFeedItem: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL

        init(localFeedItem: LocalFeedItem) {
            id = localFeedItem.id
            description = localFeedItem.description
            location = localFeedItem.location
            imageURL = localFeedItem.imageURL
        }

        var local: LocalFeedItem {
            return LocalFeedItem(id: id, description: description, location: location, imageURL: imageURL)
        }
    }

    private let queue = DispatchQueue(label: "store-queue", qos: .userInitiated, attributes: .concurrent)

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func loadFeed(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            do {
                let cachedObject = try JSONDecoder().decode(Cache.self, from: data)
                completion(.found(feed: cachedObject.feed.map { $0.local }, timestamp: cachedObject.timestamp))
            } catch(let error) {
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

    public func insertFeed(feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            do {
                let codableFeed = feed.map { CodableFeedItem(localFeedItem: $0) }
                let encodedData = try encoder.encode(Cache(feed: codableFeed, timestamp: timestamp))
                try encodedData.write(to: storeURL)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

}
