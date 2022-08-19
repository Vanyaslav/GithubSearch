//
//  UIAlert+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit

extension UIAlertAction {
    static func cancelAction() -> UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel)
    }
}
