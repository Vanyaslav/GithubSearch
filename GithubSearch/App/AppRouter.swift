//
//  AppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

class InitialContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<Void>()
}

class TrendingListContext {
    let showDetail = PublishSubject<TrendingRepoListViewModel.StandardItem>()
    let showError = PublishSubject<Error>()
    let disposeFlow = PublishSubject<Void>()
}

protocol Router {
    var navigationController: UINavigationController { get }
    var recentController: UIViewController? { get }

    func run()
    func showAlert(with title: String, message: String)
}

extension Router {
    var recentController: UIViewController? { navigationController.topViewController }
    
    func showAlert(with title: String = "", message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        navigationController
            .present(alert, animated: true)
    }
}

class TrendingRepoRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: TrendingListContext

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: TrendingListContext = TrendingListContext()) {
        self.navigationController = navigationController
        self.context = context
    }

    func run() {
        let view = TrendingRepoListViewController(with: TrendingRepoListViewModel(with: context))
        self.navigationController
            .pushViewController(view, animated: true)

        context.showDetail
            .map(TrendingRepoDetailViewModel.init(with:))
            .map(TrendingRepoDetailViewController.init(with:))
            .map { ($0, true) }
            .map(navigationController.pushViewController)
            .subscribe()
            .disposed(by: disposeBag)

        context.showError
            .map { ("", $0.localizedDescription) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)

        context.disposeFlow
            .bind { [self] in
                disposeBag.dispose()
            }.disposed(by: disposeBag)
    }
}

enum MenuEnum {
    case trending

    func router(with nc: UINavigationController?) -> Router {
        return TrendingRepoRouter(with: nc ?? UINavigationController())
    }
}

class AppRouter: Router, ApplicationProtocol {
    private let disposeBag = CompositeDisposable()
    private let context: InitialContext

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: InitialContext = InitialContext() ) {
        self.navigationController = navigationController
        self.context = context
    }

    func run() {
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
            .map(MenuEnum.trending.router)
            .map { $0.run() }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
