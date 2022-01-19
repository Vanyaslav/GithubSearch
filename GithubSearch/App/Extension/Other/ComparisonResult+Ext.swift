//
//  ComparisonResult+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 09/01/2022.
//

import Foundation

extension ComparisonResult {
    var param: String {
        switch self {
        case .orderedAscending:
            return "asc"
        case .orderedDescending:
            return "desc"
        case .orderedSame:
            return ""
        }
    }
}
