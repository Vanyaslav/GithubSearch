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
         trending,
         search
}

class InitialContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<Void>()
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

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: InitialContext = InitialContext()) {
        self.navigationController = navigationController
        self.context = context
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
            .map {
                switch style {
                case .tabBar:
                    $0.setViewControllers([MenuViewController()], animated: true)
                case .trending:
                    TrendingRepoRouter(with: $0).run(with: style)
                case .search:
                    SearchRepoRouter(with: $0).run(with: style)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
