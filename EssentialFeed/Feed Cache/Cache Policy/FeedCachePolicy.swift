//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-13.
//

import Foundation

internal final class FeedCachePolicy {

    private static let calendar = Calendar(identifier: .gregorian)

    private static var maxCacheAgaInDays: Int {
        return 7
    }

    internal static func validateTimestamp(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgaInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
