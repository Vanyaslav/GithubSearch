//
//  SearchCodeAppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import UIKit
import RxSwift

class SearchCodeContext: GenericContext {}

class SearchCodeRouter: Router {
    let disposeBag = CompositeDisposable()
    private let context: SearchCodeContext
    private let dependency: AppDefaults.Dependency
    private let splitController: UISplitViewController?
    let navigationController: UINavigationController

    let inputData: SearchCodeViewModel.InputData?

    init(with navigationController: UINavigationController? = nil,
         context: SearchCodeContext = .init(),
         dependency: AppDefaults.Dependency,
         splitController: UISplitViewController? = nil,
         inputData: SearchCodeViewModel.InputData? = nil) {
        self.navigationController = navigationController ?? .init()
        self.context = context
        self.dependency = dependency
        self.splitController = splitController
        self.inputData = inputData
    }
    
    func run(with style: AppType) {
        let view = SearchCodeViewController(with: .init(with: dependency,
                                                        context: context,
                                                        inputData: inputData))
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
            
        case .flow(type: .search(type: .code)):
            navigationController
                .pushViewController(view, animated: true)
            
        case .flow(type: .search(type: .repo)),
             .flow(type: .trending),
             .flow(type: .undefined):
            return
        }
        
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
