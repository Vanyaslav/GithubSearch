//
//  MenuRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 20/01/2022.
//

import UIKit
import RxSwift

class MenuContext {}

class MenuRouter: Router {
    private let disposeBag = CompositeDisposable()
    private let context: MenuContext

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController,
         context: MenuContext = MenuContext()) {
        self.navigationController = navigationController
        self.context = context
    }

    func run() {
        let model = MenuViewModel(with: context)
        let view = MenuViewController(with: model)
        navigationController
            .pushViewController(view, animated: true)
    }
}
