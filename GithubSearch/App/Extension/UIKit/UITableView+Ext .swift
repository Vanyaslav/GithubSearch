//
//  UITableView+Ext .swift
//  GithubSearch
//
//  Created by Tomas Baculák on 24/01/2022.
//

import UIKit

extension UITableView {
    func scrollToBottom() {
        let section = numberOfSections - 1
        if section < 0 { return }
        let row = numberOfRows(inSection: section) - 1
        if row < 0 { return }
        scrollToRow(at: IndexPath(row: row,
                                  section: section),
                    at: .bottom,
                    animated: true)
    }
}
