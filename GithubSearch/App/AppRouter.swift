//
//  AppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

enum AppType {
    case tabBar,
         menu,
         flow(type: FlowType)
         
    
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

    var icon: UIImage {
        return UIImage()
    }
    
    static var list: [Self] {
        [
            .trending,
            .search(type: .repo),
            .search(type: .code)
        ]
    }

    static var basicControllers: [UIViewController] {
        list.map { item -> UINavigationController in
            let navigation = UINavigationController()
                navigation.tabBarItem.title = item.title
                navigation.tabBarItem.image = item.icon
            return navigation
        }
    }

    init(with value: Int) {
        self = Self.list.contains{ $0 == Self.list[value] }
            ? Self.list[value]
            : .undefined
    }
}

class AppContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<Void>()
}

class AlertContext {
    let showMessage = PublishSubject<String>()
}

protocol Router {
    var navigationController: UINavigationController { get }
    var recentController: UIViewController { get }

    func run(with style: AppType)
    func showAlert(with title: String, message: String)
}

extension Router {
    var recentController: UIViewController {
        navigationController.topViewController ?? navigationController
    }
    
    func showAlert(with title: String = "", message: String) {
        guard navigationController.presentedViewController is UIAlertController
        else {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            navigationController
                .present(alert, animated: true)
            return
        }
    }
}

class AppRouter: Router, ApplicationProtocol {
    private let disposeBag = CompositeDisposable()
    private let context: AppContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: AppContext = AppContext(),
         dependency: AppDefaults.Dependency = AppDefaults.Dependency()) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
    }

    func run(with style: AppType = AppDefaults.appType) {
        let model = InitialViewModel(with: context)
        let view = InitialViewController(with: model)
        navigationController
            .pushViewController(view, animated: true)

        context.showWebSite
            .map(showWebLink)
            .subscribe()
            .disposed(by: disposeBag)

        context.startApp
            .map { [self] in navigationController }
            .map { [self] nc -> Router? in
                switch style {
                case .tabBar:
                    return TabBarRouter(with: nc, dependency: dependency)
                case .flow(type: .trending):
                    return TrendingRepoRouter(with: nc, dependency: dependency)
                case .flow(type: .search(type: .repo)):
                    return SearchRepoRouter(with: nc, dependency: dependency)
                case .flow(type: .search(type: .code)):
                    return SearchRepoRouter(with: nc, dependency: dependency)
                case .flow(type: .undefined):
                    return  nil
                case .menu:
                    return nil
                }
            }.unwrap()
            .map { $0.run(with: style) }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
