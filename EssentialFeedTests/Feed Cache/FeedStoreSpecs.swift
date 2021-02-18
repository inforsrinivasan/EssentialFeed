//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Srinivasan Rajendran on 2021-02-16.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues()

    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieveDeliversFailureOnRetrievalError()
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
}

protocol FailableDeletionFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableDeletionFeedStoreSpecs
