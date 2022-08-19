//
//  UIAlertController+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit

extension UIAlertController {
    static func loadActionSheet(_ title: String) -> UIAlertController {
        UIAlertController(title: title,
                          message: nil,
                          preferredStyle: .actionSheet)
    }
}
