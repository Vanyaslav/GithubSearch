//
//  AppType.FlowType+Routes.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit

extension AppType.FlowType {
    func router(with nc: UINavigationController? = nil,
                dependency: AppDefaults.Dependency,
                splitController: UISplitViewController? = nil) -> Router? {
        switch self {
            case .search(.repo):
                return SearchRepoRouter(with: nc, dependency: dependency, splitController: splitController)
            case .search(type: .code):
                return SearchCodeRouter(with: nc, dependency: dependency, splitController: splitController)
            case .trending:
                return TrendingRepoRouter(with: nc, dependency: dependency, splitController: splitController)
            case .undefined:
                return nil
        }
    }
}
