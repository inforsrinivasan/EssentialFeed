//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-02-02.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    private struct UnexpectedValuesRepresentation: Error {}

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
