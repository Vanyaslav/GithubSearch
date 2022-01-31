//
//  SearchRepoRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit
import RxSwift

class SearchRepoContext: SearchCodeContext {}

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
    
    func run(with style: AppType) {
        let view = SearchRepoViewController(with: SearchRepoViewModel(with: dependency,
                                                                      context: context))
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .flow(type: .search(type: .repo)):
            navigationController
                .pushViewController(view, animated: true)
        default:
            return
        }
        
        context.showMessage
            .map { ("", $0) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
