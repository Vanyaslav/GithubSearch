//
//  TabBarAppRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 31/01/2022.
//

import UIKit
import RxSwift

class TabBarRouter: Router  {
    let disposeBag = CompositeDisposable()
    
    let navigationController: UINavigationController
    private let dependency: AppDefaults.Dependency
    
    init(with navigationController: UINavigationController,
         dependency: AppDefaults.Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }
    
    func run(with style: AppType) {
        switch style {
        case .tabBar:
            let view = TabBarViewController()
            view.viewControllers?.enumerated()
                .map { (offset, element) -> Router? in
                    guard let nc = element as? UINavigationController
                    else { return nil }
                    return AppType.FlowType(with: offset)
                        .router(with: nc,
                                dependency: dependency)
                }.compactMap { $0 }
                .forEach { $0.run(with: style) }
            
            navigationController
                .setViewControllers([view], animated: true)
        default:
            break
        }
    }
}
