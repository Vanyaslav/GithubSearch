//
//  AppType.FlowType.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit

extension AppType {
    enum FlowType {
        case search(type: SearchType),
             trending,
             undefined
        
        enum SearchType {
            case code, repo
        }
    }
}

extension AppType.FlowType: Equatable {
    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .search(type: .code):
            return "Search code"
        case .search(type: .repo):
            return "Search repo"
        case .undefined:
            return "??"
        }
    }

    var icon: UIImage? {
        switch self {
        case .trending:
            return UIImage(systemName: "chart.line.uptrend.xyaxis")
        case .search(type: let type):
            switch type {
            case .code:
                return UIImage(systemName: "doc.text.magnifyingglass")
            case .repo:
                return UIImage(systemName: "magnifyingglass.circle.fill")
            }
        case .undefined:
            return UIImage(systemName: "questionmark.app.fill")
        }
    }
    
    static var list: [Self] {
        [
            .trending,
            .search(type: .repo),
            .search(type: .code)
        ]
    }
    
    static var titles: [String] {
        list.map { $0.title }
    }

    static var basicControllers: [UIViewController] {
        list.map {
            let navigation = UINavigationController()
                navigation.tabBarItem.title = $0.title
                navigation.tabBarItem.image = $0.icon
            return navigation
        }
    }

    init(with value: Int) {
        self = Self.list.contains { $0 == Self.list[value] }
            ? Self.list[value]
            : .undefined
    }
}
