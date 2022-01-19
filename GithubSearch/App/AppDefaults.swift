//
//  AppDefaults.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import Foundation
import UIKit

struct AppDefaults {
    // api token needs to be replaced with personal one (XXXXXXXX to be replaced)
    // https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
    static let apiToken = "token XXXXXXXX"
    // number of days which reflects the trending github repository loaded data in TrendingRepoListViewModel
    // example value 7 will set the start date a week before today
    static let trendingPeriod: UInt = 200
    // number of trending repositories taken by pagination in the table (TrendingRepoListViewController)
    // Results per page (max 100)
    static let numberOfRepositories: UInt = 20
}

protocol UIObjectStyle {
    var color: UIColor { get }
    var fontSize: CGFloat { get }
}

extension AppDefaults {
    // default UI
    enum Style: UIObjectStyle {
        case small

        var color: UIColor {
            return .white
        }
        var fontSize: CGFloat {
            return 12
        }
    }
}
