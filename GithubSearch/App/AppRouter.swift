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

enum AppType: CaseIterable, Equatable {
    static var allCases: [AppType] = [.tabBar, .menu, .flow(type: .undefined)]
    
    case tabBar,
         menu,
         flow(type: FlowType)
    
    var title: String {
        switch self {
        case .tabBar:
            return "Tab bar"
        case .menu:
            return "Menu"
        case .flow(_):
            return "Flow"
        }
    }
    
         
    
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

class AppContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<AppType>()
    let shoOptionsAlert = PublishSubject<Void>()
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

extension AppType.FlowType {
    fileprivate func processFlow(context: AppContext) -> UIAlertAction {
        UIAlertAction(title: title,
                      style: .default,
                      handler: { _ in
            context
                .startApp
                .onNext(AppType.flow(type: self))
            })
    }
}

extension AppType {
    fileprivate func processFlow(
        context: AppContext,
        router:  AppRouter
    ) -> UIAlertAction {
        UIAlertAction(title: title,
                      style: .default,
                      handler: { _ in
            guard self == .flow(type: .undefined) else {
                context.startApp.onNext(self)
                return
            }
            router.showFlowOptions()
        })
    }
}

extension UIAlertController {
    static func loadActionSheet(_ title: String) -> UIAlertController {
        UIAlertController(title: title,
                          message: nil,
                          preferredStyle: .actionSheet)
    }
}

extension UIAlertAction {
    static func cancelAction() -> UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel)
    }
}

extension AppRouter {
    func showFlowOptions() {
        let alert = UIAlertController.loadActionSheet("Choose Flow type")
        AppType.FlowType.list.forEach { item in
            alert.addAction(item.processFlow(context: context))
        }
        
        alert.addAction(UIAlertAction.cancelAction())
        navigationController
            .present(alert, animated: true)
    }
    
    func showOptions() {
        let alert = UIAlertController.loadActionSheet("Choose App type")
        AppType.allCases.forEach { item in
            alert.addAction(item.processFlow(context: context, router: self))
        }
        
        alert.addAction(UIAlertAction.cancelAction())
        navigationController
            .present(alert, animated: true)
    }
}

class AppRouter: Router, ApplicationProtocol {
    let disposeBag = CompositeDisposable()
    private let context: AppContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with
         window: UIWindow,
         navigationController: UINavigationController = UINavigationController(),
         context: AppContext = AppContext(),
         dependency: AppDefaults.Dependency = AppDefaults.Dependency()
    ) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func run(with style: AppType = .tabBar) {
        let model = InitialViewModel(with: context)
        let view = InitialViewController(with: model)
        navigationController
            .pushViewController(view, animated: true)

        context.showWebSite
            .map(showWebLink)
            .subscribe()
            .disposed(by: disposeBag)
        
        context
            .shoOptionsAlert
            .map { [self] in showOptions() }
            .subscribe()
            .disposed(by: disposeBag)
        
        context.startApp
            .map { [self] style in
                guard let router = style.router(with: navigationController,
                                                dependency: dependency)
                else { return }
                router.run(with: style)
                if style == .tabBar || style == .menu {
                    disposeFlow()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
