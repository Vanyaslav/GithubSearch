//
//  SearchRepoAppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit
import RxSwift

class SearchRepoContext: SearchCodeContext {
    let showCodeSearch = PublishSubject<SearchCodeViewModel.InputData>()
}

class SearchRepoRouter: Router {
    let disposeBag = CompositeDisposable()
    private let context: SearchRepoContext
    private let dependency: AppDefaults.Dependency
    private var splitController: UISplitViewController?
    let navigationController: UINavigationController

    init(with navigationController: UINavigationController? = nil,
         context: SearchRepoContext = SearchRepoContext(),
         dependency: AppDefaults.Dependency,
         splitController: UISplitViewController? = nil) {
        self.navigationController = navigationController ?? UINavigationController()
        self.context = context
        self.dependency = dependency
        self.splitController = splitController
    }
    
    func run(with style: AppType) {
        let view = SearchRepoViewController(with: SearchRepoViewModel(with: dependency,
                                                                      context: context))
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
        case .flow(type: .search(type: .repo)):
            navigationController
                .pushViewController(view, animated: true)
        default:
            return
        }

        context.showCodeSearch
            .map { [self] in
                SearchCodeRouter(with: navigationController,
                                 dependency: dependency,
                                 inputData: $0)
                .run(with: .flow(type: .search(type: .code))) }
            .subscribe()
            .disposed(by: disposeBag)
        
        context.showMessage
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
