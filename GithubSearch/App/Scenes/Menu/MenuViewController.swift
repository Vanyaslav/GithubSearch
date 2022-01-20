//
//  MenuViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import Foundation
import UIKit

enum MenuEnum {
    case trending

    func router(with nc: UINavigationController? = nil) -> Router {
        return TrendingRepoRouter(with: nc ?? UINavigationController())
    }
}

class MenuViewModel {
    init(with context: MenuContext) {
        
    }
}

class MenuViewController: UITabBarController {
    private let viewModel: MenuViewModel

    init(with viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        let trendingItem = MenuEnum.trending.router()
        trendingItem.run()
        trendingItem.recentController?.formatTabBarSubViews(with: "Trending")
        let settingsItem = UIViewController()
        settingsItem.formatTabBarSubViews(with: "Settings")
        viewControllers = [trendingItem.recentController ?? UIViewController(), settingsItem]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIViewController {
    func formatTabBarSubViews(with title: String) {
        guard let nc = navigationController
        else {
            return
        }
        nc.tabBarItem.title = title
        nc.navigationBar.prefersLargeTitles = true
        nc.tabBarItem.image = UIImage(named: "Octocat")
        //navigationItem.title = title
    }
}
