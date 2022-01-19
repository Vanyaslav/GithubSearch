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

    func run()
    func showAlert(with title: String, message: String)
}

extension Router {
    func showAlert(with title: String = "", message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        navigationController
            .present(alert, animated: true)
    }
}

class TrendingListRouter: Router {
    private let disposeBag = CompositeDisposable()
    let navigationController: UINavigationController

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func run() {
        let context = TrendingListContext()
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

class AppRouter: Router, ApplicationProtocol {
    private let disposeBag = CompositeDisposable()
    let navigationController: UINavigationController

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func run() {
        let context = InitialContext()
        let model = InitialViewModel(with: context)
        let view = InitialViewController(with: model)
        navigationController
            .pushViewController(view, animated: true)

        context.showWebSite
            .map(showWebLink)
            .subscribe()
            .disposed(by: disposeBag)

        context.startApp
            .map{ [self] in navigationController }
            .map(TrendingListRouter.init)
            .map { $0.run() }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
