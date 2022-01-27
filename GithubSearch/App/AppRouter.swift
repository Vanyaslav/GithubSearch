//
//  AppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

enum AppStyle {
    case tabBar,
         flow(type: FlowType)
         
    
    enum FlowType {
        case search(type: SearchType),
             trending
        
        enum SearchType {
            case code, repo
        }
    }
}

class InitialContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<Void>()
}

class AlertContext {
    let showError = PublishSubject<String>()
}

protocol Router {
    var navigationController: UINavigationController { get }
    var recentController: UIViewController { get }

    func run(with style: AppStyle)
    func showAlert(with title: String, message: String)
}

extension Router {
    var recentController: UIViewController {
        navigationController.topViewController ?? navigationController
    }
    
    func showAlert(with title: String = "", message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        navigationController
            .present(alert, animated: true)
    }
}

class AppRouter: Router, ApplicationProtocol {
    private let disposeBag = CompositeDisposable()
    private let context: InitialContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: InitialContext = InitialContext(),
         dependency: AppDefaults.Dependency = AppDefaults.Dependency()) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
    }

    func run(with style: AppStyle = AppDefaults.appStyle) {
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
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
