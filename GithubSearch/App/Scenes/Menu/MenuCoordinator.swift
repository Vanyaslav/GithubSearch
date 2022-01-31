//
//  MenuCoordinator.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 29/01/2022.
//

import UIKit

extension UISplitViewController {
    convenience init(rootViewController: UIViewController) {
        self.init()
        preferredDisplayMode = .allVisible
        viewControllers = [rootViewController]
    }
}

class MenuRouter {
    init(with nc: UINavigationController) {
        let view = MenuViewController()
        let rootView = UINavigationController(rootViewController: view)
        let mainController = UISplitViewController(rootViewController: rootView)
        nc.setViewControllers([mainController],
                              animated: true)
        
//        context.itemSelected
//            .map{ $0.getCoordinator(with: mainController) }
//            .subscribe()
//            .disposed(by: disposeBag)
    }
}
