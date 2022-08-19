//
//  TrendingRepoAppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import UIKit
import RxSwift

class TrendingRepoContext: AlertContext {
    let showDetail = PublishSubject<TrendingRepoListViewModel.StandardItem>()
}

class TrendingRepoRouter: Router {
    let disposeBag = CompositeDisposable()
    private let context: TrendingRepoContext
    private let dependency: AppDefaults.Dependency
    private var splitController: UISplitViewController?

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController? = nil,
         context: TrendingRepoContext = TrendingRepoContext(),
         dependency: AppDefaults.Dependency,
         splitController: UISplitViewController? = nil) {
        self.navigationController = navigationController ?? UINavigationController()
        self.context = context
        self.dependency = dependency
        self.splitController = splitController
    }

    func run(with style: AppType) {
        let view = TrendingRepoListViewController(with: TrendingRepoListViewModel(with: context,
                                                                                  dependency: dependency))
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .menu:
            guard let splitController = splitController
            else { return }
            navigationController
                .setViewControllers([view], animated: true)
            splitController
                .showDetailViewController(navigationController, sender: nil)
        case .flow(type: .trending) :
            navigationController
                .pushViewController(view, animated: true)
        default:
            return
        }

        context.showDetail
            .map(TrendingRepoDetailViewModel.init)
            .map(TrendingRepoDetailViewController.init)
            .map { ($0, true) }
            .map(navigationController.pushViewController)
            .subscribe()
            .disposed(by: disposeBag)

        context.showMessage
            .map { ("", $0) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)

        context.disposeFlow
            .bind { [self] in disposeFlow() }
            .disposed(by: disposeBag)
    }
}
