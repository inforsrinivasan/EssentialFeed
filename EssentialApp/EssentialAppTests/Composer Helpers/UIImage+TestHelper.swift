//
//  UIImage+TestHelper.swift
//  EssentialFeedMVP_iOSTests
//
//  Created by Srinivasan Rajendran on 2021-03-11.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let cgRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(cgRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(cgRect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
