//
//  TrendingRepoRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import UIKit
import RxSwift

class TrendingRepoRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: TrendingRepo.Context
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: TrendingRepo.Context = TrendingRepo.Context(),
         dependency: AppDefaults.Dependency) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
    }

    func run(with style: AppStyle) {
        let view = TrendingRepoListViewController(with: TrendingRepoListViewModel(with: context,
                                                                                  dependency: dependency))
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .trending:
            navigationController
                .pushViewController(view, animated: true)
        case .search:
            break
        }

        context.showDetail
            .map(TrendingRepoDetailViewModel.init(with:))
            .map(TrendingRepoDetailViewController.init(with:))
            .map { ($0, true) }
            .map(navigationController.pushViewController)
            .subscribe()
            .disposed(by: disposeBag)

        context.showError
            .map { ("", $0) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)

        context.disposeFlow
            .bind { [self] in
                disposeBag.dispose()
            }.disposed(by: disposeBag)
    }
}
