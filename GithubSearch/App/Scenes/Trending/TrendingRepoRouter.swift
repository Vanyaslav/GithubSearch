//
//  TrendingRepoRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import UIKit
import RxSwift

class TrendingRepoContext {
    let showDetail = PublishSubject<TrendingRepoListViewModel.StandardItem>()
    let showError = PublishSubject<Error>()
    let disposeFlow = PublishSubject<Void>()
}

class TrendingRepoRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: TrendingRepoContext

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: TrendingRepoContext = TrendingRepoContext()) {
        self.navigationController = navigationController
        self.context = context
    }

    func run() {
        let view = TrendingRepoListViewController(with: TrendingRepoListViewModel(with: context))
        self.navigationController
            .pushViewController(view, animated: true)

        context.showDetail.debug()
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
