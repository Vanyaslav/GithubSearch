//
//  Sequence+Unique.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 29/01/2022.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
