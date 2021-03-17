//
//  UITableView+Dequeuing.swift
//  EssentialFeedMVP_iOS
//
//  Created by Srinivasan Rajendran on 2021-03-10.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
