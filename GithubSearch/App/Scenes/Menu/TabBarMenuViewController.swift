//
//  TabBarMenuViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import Foundation
import UIKit

class TabBarRouter: Router  {
    let navigationController: UINavigationController
    private let dependency: AppDefaults.Dependency
    
    init(with navigationController: UINavigationController,
         dependency: AppDefaults.Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }
    
    func run(with style: AppType) {
        switch style {
        case .tabBar:
            let view = TabBarMenuViewController()
            _ = view.viewControllers?.enumerated()
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
                .map { $0.run(with: style) }
            
            navigationController
                .setViewControllers([view], animated: true)
        default:
            break
        }
    }
    
    
}

class TabBarMenuViewController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = AppType.FlowType.basicControllers
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
