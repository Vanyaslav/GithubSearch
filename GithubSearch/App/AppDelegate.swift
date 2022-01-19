//
//  AppDelegate.swift
//  XapoTest
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nc = UINavigationController()
        window?.rootViewController = nc
        window?.makeKeyAndVisible()

        AppRouter(with: nc).run()
        return true
    }
}

extension AppDelegate {
    
}

