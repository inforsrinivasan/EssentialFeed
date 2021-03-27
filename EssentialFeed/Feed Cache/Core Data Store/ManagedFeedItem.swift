//
//  ManagedFeedItem.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-24.
//

import CoreData

@objc(ManagedFeedItem)
class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
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

    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedItem? {
        let request = NSFetchRequest<ManagedFeedItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedItem.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    var local: LocalFeedItem {
        return LocalFeedItem(id: id, description: imageDescription, location: location, imageURL: url)
    }
}

