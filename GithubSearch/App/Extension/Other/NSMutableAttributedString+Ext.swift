//
//  NSMutableAttributedString+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import Foundation
import UIKit

extension String {
    func smallUnderline(with color: UIColor = AppDefaults.Style.small.color) -> NSMutableAttributedString {
        let yourAttributes: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: AppDefaults.Style.small.fontSize),
              .foregroundColor: color,
              .underlineStyle: NSUnderlineStyle.single.rawValue
          ]

        let attributeString = NSMutableAttributedString(
                string: self,
                attributes: yourAttributes
             )
        return attributeString
    }
}
