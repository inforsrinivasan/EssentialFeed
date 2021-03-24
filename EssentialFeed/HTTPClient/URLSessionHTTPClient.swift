//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-02.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    private struct UnexpectedValuesRepresentation: Error {}

    public init(session: URLSession) {
        self.session = session
    }

    public func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()

        return URLSessionTaskWrapper(wrapped: task)
    }
}

private struct URLSessionTaskWrapper: HTTPClientTask {

    private let wrapped: URLSessionTask

    init(wrapped: URLSessionTask) {
        self.wrapped = wrapped
    }

    func cancel() {
        wrapped.cancel()
    }

}
