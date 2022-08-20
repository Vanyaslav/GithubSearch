//
//  UIAlertController+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit

extension UIAlertController {
    static func loadActionAlert(_ title: String) -> UIAlertController {
        let alertStyle = UIDevice.current.userInterfaceIdiom == .pad
        ? UIAlertController.Style.alert
        : UIAlertController.Style.actionSheet
        return UIAlertController(title: title,
                          message: nil,
                          preferredStyle: alertStyle)
    }
}
