//
//  SearchRepoRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit
import RxSwift

class SearchRepoContext {
    let showError = PublishSubject<String>()
}

class SearchRepoRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: SearchRepoContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: SearchRepoContext = SearchRepoContext(),
         dependency: AppDefaults.Dependency) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
    }
    
    func run(with style: AppStyle) {
        let view = SearchRepoViewController(with: SearchRepoViewModel( with: dependency,
                                                                       context: context))
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .search:
            navigationController
                .pushViewController(view, animated: true)
        default:
            break
        }
        
        context.showError
            .map { ("", $0) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
