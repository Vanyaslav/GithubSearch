//
//  AppType+Routes.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import Foundation
import UIKit

extension AppType {
    func router(with nc: UINavigationController,
                dependency: AppDefaults.Dependency) -> Router? {
        switch self {
        case .tabBar:
            return TabBarRouter(with: nc, dependency: dependency)
        case .menu:
            return MenuRouter(with: nc, dependency: dependency)
        case .flow(let type):
            return type.router(with: nc, dependency: dependency)
        }
    }
}

extension AppType {
    func processFlow(context: AppContext, router:  AppRouter) -> UIAlertAction {
        .init(title: title, style: .default, handler: { _ in
            guard self == .flow(type: .undefined) else {
                context.startApp.onNext(self)
                return
            }
            router.showFlowOptions()
        })
    }
}
