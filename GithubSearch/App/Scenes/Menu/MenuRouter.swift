//
//  MenuAppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 29/01/2022.
//

import UIKit
import RxSwift

extension UISplitViewController {
    convenience init(rootViewController: UIViewController) {
        self.init()
        preferredDisplayMode = .allVisible
        viewControllers = [rootViewController]
    }
}

class MenuRouter: Router {
    let disposeBag = CompositeDisposable()
    private let dependency: AppDefaults.Dependency
    private let splitController: UISplitViewController
    let navigationController: UINavigationController
    
    private let context: MenuContext
    
    init(with nc: UINavigationController,
         context: MenuContext = .init(),
         dependency: AppDefaults.Dependency) {
        self.navigationController = nc
        self.context = context
        self.dependency = dependency
        
        let view = MenuViewController(with: .init(with: context))
        let rootView = UINavigationController(rootViewController: view)
        let mainController = UISplitViewController(rootViewController: rootView)
        splitController = mainController
        UIApplication.shared.windows.first?.rootViewController = mainController
    }
    
    func run(with style: AppType) {
        context.selectedItem
            .map { [self] item in
                AppType.FlowType(with: item)
                    .router(dependency: dependency,
                            splitController: splitController) }
            .unwrap()
            .withPrevious()
            .map { (previousRouter, router) in
                if let pRouter = previousRouter {
                    pRouter.disposeFlow()
                }
                router.run(with: style)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
