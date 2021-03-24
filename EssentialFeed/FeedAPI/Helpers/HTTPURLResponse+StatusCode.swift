//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Srinivasan Rajendran on 2021-03-20.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
