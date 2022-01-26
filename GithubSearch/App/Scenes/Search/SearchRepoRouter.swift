//
//  SearchRepoRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit
import RxSwift

class SearchRepoContext {
    
}

class SearchRepoRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: SearchRepoContext

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: SearchRepoContext = SearchRepoContext()) {
        self.navigationController = navigationController
        self.context = context
    }
    
    func run(with style: AppStyle) {
        let view = SearchRepoViewController(with: SearchRepoViewModel())
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .search:
            self.navigationController
                .pushViewController(view, animated: true)
        default:
            break
        }
    }
}
