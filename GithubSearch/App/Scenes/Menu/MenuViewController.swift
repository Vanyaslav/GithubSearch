//
//  MenuViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import Foundation
import UIKit
import RxSwift

enum MenuItem: Int, CaseIterable {
    case trending, search
    
    var icon: UIImage {
        return UIImage()
    }
    
    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .search:
            return "Search"
        }
    }
    
    static var basicControllers: [UIViewController] {
        Self.allCases
            .map { item -> UINavigationController in
                let navigation = UINavigationController()
                navigation.tabBarItem.title = item.title
                navigation.tabBarItem.image = item.icon
                return navigation
            }
    }
}


class MenuViewController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = MenuItem.basicControllers
                
        _ = viewControllers?.enumerated()
            .map { (offset, element) -> Router? in
                guard let items = MenuItem(rawValue: offset),
                      let nc = element as? UINavigationController
                else { return nil }
                
                switch items {
                case .trending:
                    return TrendingRepoRouter(with: nc)
                case .search:
                    return SearchRepoRouter(with: nc)
                }
            }.compactMap { $0 }
            .map { $0.run(with: .tabBar) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
