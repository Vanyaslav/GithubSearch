//
//  TabBarMenuViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import Foundation
import UIKit

class TabBarMenuViewController: UITabBarController {
    init(with dependency: AppDefaults.Dependency) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = AppType.FlowType.basicControllers
                
        _ = viewControllers?.enumerated()
            .map { (offset, element) -> Router? in
                guard let nc = element as? UINavigationController
                else { return nil }
                
                switch AppType.FlowType(with: offset) {
                case .trending:
                    return TrendingRepoRouter(with: nc, dependency: dependency)
                case .search(type: .repo):
                    return SearchRepoRouter(with: nc, dependency: dependency)
                case .search(type: .code):
                    return SearchCodeRouter(with: nc, dependency: dependency)
                case .undefined:
                    return nil
                }
            }.compactMap { $0 }
            .map { $0.run(with: .tabBar) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
