//
//  AppDelegate.swift
//  XapoTest
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nc = UINavigationController()
        window?.rootViewController = nc
        window?.makeKeyAndVisible()

        AppRouter(with: nc)
            .run()
        
//        #if DEBUG
//        Observable<Int>
//            .interval(.seconds(1), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { _ in print("Resource count \(RxSwift.Resources.total)") })
//            .disposed(by: disposeBag)
//        #endif
        return true
    }
}
