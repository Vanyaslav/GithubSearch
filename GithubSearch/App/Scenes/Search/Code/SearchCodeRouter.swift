//
//  SearchCodeRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import UIKit
import RxSwift

class SearchCodeContext: AlertContext {}

class SearchCodeRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: SearchCodeContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: SearchCodeContext = SearchCodeContext(),
         dependency: AppDefaults.Dependency) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
    }
    
    func run(with style: AppType) {
        let view = SearchCodeViewController(with: SearchCodeViewModel( with: dependency,
                                                                       context: context))
        switch style {
        case .tabBar:
            navigationController
                .setViewControllers([view], animated: true)
        case .flow(type: .search(type: .code)):
            navigationController
                .pushViewController(view, animated: true)
        default:
            return
        }
        
        context.showError
            .map { ("", $0) }
            .map(showAlert)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
