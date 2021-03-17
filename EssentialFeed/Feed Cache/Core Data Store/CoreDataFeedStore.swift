//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-17.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = self.context
        context.perform {
            do {
                try ManagedCache.find(in: context)
                    .map(context.delete)
                    .map(context.save)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

    public func insertFeed(feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedItem.items(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }

    public func loadFeed(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed,
                                      timestamp: cache.timestamp)
                    )
                } else {
                    completion(.empty)
                }

            } catch(let error) {
                completion(.failure(error))
            }
        }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet

    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }

    var localFeed: [LocalFeedItem] {
        return feed.compactMap { ($0 as? ManagedFeedItem)?.local }
    }
}

@objc(ManagedFeedItem)
private class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache

    static func items(from localFeed: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedItem(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.imageURL
            return managed
        })
    }

    var local: LocalFeedItem {
        return LocalFeedItem(id: id, description: imageDescription, location: location, imageURL: url)
    }
}

private extension NSPersistentContainer {

    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStore(Swift.Error)
    }

    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        var loadError: Swift.Error?
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}