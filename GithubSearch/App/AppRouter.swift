//
//  MainRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

extension AppType {
    func router(with nc: UINavigationController,
                dependency: AppDefaults.Dependency) -> Router? {
        switch self {
        case .tabBar:
            return TabBarRouter(with: nc, dependency: dependency)
        case .menu:
            return MenuRouter(with: nc, dependency: dependency)
        case .flow(let type):
            return type.router(with: nc, dependency: dependency)
        }
    }
}

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
    
    private static var list: [Self] {
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
    let disposeFlow = PublishSubject<Void>()
}

protocol Router {
    var navigationController: UINavigationController { get }
    var disposeBag: CompositeDisposable { get }
    var recentController: UIViewController { get }

    func run(with style: AppType)
    func showAlert(with title: String, message: String)
    func disposeFlow()
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
    
    func disposeFlow() {
        disposeBag.dispose()
    }
}

class AppRouter: Router, ApplicationProtocol {
    let disposeBag = CompositeDisposable()
    private let context: AppContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with window: UIWindow,
         navigationController: UINavigationController = UINavigationController(),
         context: AppContext = AppContext(),
         dependency: AppDefaults.Dependency = AppDefaults.Dependency()) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
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
            .map { [self] in
                style.router(with: navigationController,
                             dependency: dependency)
            }.unwrap()
            .map { $0.run(with: style) ; self.disposeBag.dispose() }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
