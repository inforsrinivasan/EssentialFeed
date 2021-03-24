//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-01-31.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    @discardableResult
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask
}
