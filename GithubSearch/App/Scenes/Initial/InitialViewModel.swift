//
//  InitialViewModel.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//
import Foundation
import RxSwift
// linx
extension InitialViewModel {
    struct Linx {
        static let mainWebSite = "https://github.com"
        static let docsSite = "https://docs.github.com/en"
        static let infoSite = "https://github.com/about"
    }
}
// animation
extension InitialViewModel {
    // in ms
    static let progressDelay: UInt = 500
}

extension UInt {
    var intervalFromMiliseconds: TimeInterval {
        Double(self) / 1000
    }
}

class InitialViewModel {
    private let disposeBag = DisposeBag()
    // in
    let navigateToMain = PublishSubject<Void>()
    let navigateToInfo = PublishSubject<Void>()
    let navigateToDocs = PublishSubject<Void>()

    let startApp = PublishSubject<Void>()

    init(with context: InitialContext) {
        navigateToMain
            .map { Linx.mainWebSite }
            .bind(to: context.showWebSite)
            .disposed(by: disposeBag)

        navigateToInfo
            .map { Linx.infoSite }
            .bind(to: context.showWebSite)
            .disposed(by: disposeBag)

        navigateToDocs
            .map { Linx.docsSite }
            .bind(to: context.showWebSite)
            .disposed(by: disposeBag)

        startApp
            .delay(DispatchTimeInterval.milliseconds(Int(Self.progressDelay)),
                   scheduler: MainScheduler.instance)
            .bind(to: context.startApp)
            .disposed(by: disposeBag)
    }
}
