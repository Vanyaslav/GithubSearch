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

extension AppType.FlowType {
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

    static var basicControllers: [UIViewController] {
        [
            AppType.FlowType.trending,
            .search(type: .repo),
            .search(type: .code)
        ]
            .map { item -> UINavigationController in
                let navigation = UINavigationController()
                navigation.tabBarItem.title = item.title
                navigation.tabBarItem.image = item.icon
                return navigation
            }
    }

    init(with value: Int) {
        switch value {
        case 0:
            self = .trending
        case 1:
            self = .search(type: .repo)
        case 2:
            self = .search(type: .code)
        default:
            self = .undefined
        }
    }
}

class AppContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<Void>()
}

class AlertContext {
    let showError = PublishSubject<String>()
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

    func run(with style: AppType = AppDefaults.AppType) {
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
            .map { [self] in
                switch style {
                case .tabBar:
                    $0.setViewControllers([MenuViewController(with: dependency)], animated: true)
                case .flow(type: .trending):
                    TrendingRepoRouter(with: $0, dependency: dependency).run(with: style)
                case .flow(type: .search(type: .repo)):
                    SearchRepoRouter(with: $0, dependency: dependency).run(with: style)
                case .flow(type: .search(type: .code)):
                    SearchRepoRouter(with: $0, dependency: dependency).run(with: style)
                case .flow(type: .undefined):
                    break
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
