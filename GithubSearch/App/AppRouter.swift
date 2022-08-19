//
//  MainRouter.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

class AppContext {
    let showWebSite = PublishSubject<String>()
    let startApp = PublishSubject<AppType>()
    let shoOptionsAlert = PublishSubject<Void>()
}

class AlertContext {
    let showMessage = PublishSubject<String>()
    let disposeFlow = PublishSubject<Void>()
}

extension AppType.FlowType {
    fileprivate func processFlow(context: AppContext) -> UIAlertAction {
        UIAlertAction(title: title,
                      style: .default,
                      handler: { _ in
            context
                .startApp
                .onNext(AppType.flow(type: self))
            })
    }
}

extension AppType {
    fileprivate func processFlow(
        context: AppContext,
        router:  AppRouter
    ) -> UIAlertAction {
        UIAlertAction(title: title,
                      style: .default,
                      handler: { _ in
            guard self == .flow(type: .undefined) else {
                context.startApp.onNext(self)
                return
            }
            router.showFlowOptions()
        })
    }
}

extension AppRouter {
    func showFlowOptions() {
        let alert = UIAlertController.loadActionSheet("Choose Flow type")
        AppType.FlowType.list.forEach { item in
            alert.addAction(item.processFlow(context: context))
        }
        alert.addAction(UIAlertAction.cancelAction())
        navigationController
            .present(alert, animated: true)
    }
    
    func showOptions() {
        let alert = UIAlertController.loadActionSheet("Choose App type")
        AppType.allCases.forEach { item in
            alert.addAction(item.processFlow(context: context, router: self))
        }
        alert.addAction(UIAlertAction.cancelAction())
        navigationController
            .present(alert, animated: true)
    }
}

class AppRouter: Router, ApplicationProtocol {
    let disposeBag = CompositeDisposable()
    private let context: AppContext
    private let dependency: AppDefaults.Dependency

    let navigationController: UINavigationController

    init(with
         window: UIWindow,
         navigationController: UINavigationController = UINavigationController(),
         context: AppContext = AppContext(),
         dependency: AppDefaults.Dependency = AppDefaults.Dependency()
    ) {
        self.navigationController = navigationController
        self.context = context
        self.dependency = dependency
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func run(with style: AppType = .tabBar) {
        let model = InitialViewModel(with: context)
        let view = InitialViewController(with: model)
        navigationController
            .pushViewController(view, animated: true)

        context.showWebSite
            .map(showWebLink)
            .subscribe()
            .disposed(by: disposeBag)
        
        context
            .shoOptionsAlert
            .map { [self] in showOptions() }
            .subscribe()
            .disposed(by: disposeBag)
        
        context.startApp
            .map { [self] style in
                guard let router = style.router(with: navigationController,
                                                dependency: dependency)
                else { return }
                router.run(with: style)
                if style == .tabBar || style == .menu {
                    disposeFlow()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
