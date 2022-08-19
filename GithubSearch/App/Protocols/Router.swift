//
//  Router.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import UIKit
import RxSwift

protocol Router {
    var navigationController: UINavigationController { get }
    var disposeBag: CompositeDisposable { get }
    var recentController: UIViewController { get }

    func run(with style: AppType)
    func showAlert(with title: String, message: String)
    func disposeFlow()
}

extension Router {
    var recentController: UIViewController {
        navigationController.topViewController ?? navigationController
    }
    
    func showAlert(with title: String = "", message: String) {
        guard navigationController.presentedViewController is UIAlertController
        else {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            navigationController
                .present(alert, animated: true)
            return
        }
    }
    
    func disposeFlow() {
        disposeBag.dispose()
    }
}
