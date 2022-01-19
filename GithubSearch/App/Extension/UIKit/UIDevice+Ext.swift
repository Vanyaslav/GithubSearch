//
//  UIDevice+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit

extension UIDevice {
    static var includesSafeArea: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows
                .filter { $0.isKeyWindow }
                .first?
                .safeAreaInsets
                .bottom ?? 0 > 0
        }
        return false
   }
}
