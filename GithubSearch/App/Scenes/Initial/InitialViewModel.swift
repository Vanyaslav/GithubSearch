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
    enum Linx: String {
        case mainWebSite = "https://github.com"
        case docsSite = "https://docs.github.com/en"
        case infoSite = "https://github.com/about"
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
    let navigateTo = PublishSubject<Linx>()

    let startApp = PublishSubject<Void>()

    init(with context: AppContext) {
        navigateTo
            .map { $0.rawValue }.debug()
            .bind(to: context.showWebSite)
            .disposed(by: disposeBag)

        startApp
            .delay(DispatchTimeInterval.milliseconds(Int(Self.progressDelay)),
                   scheduler: MainScheduler.instance)
            .bind(to: context.startApp)
            .disposed(by: disposeBag)
    }
}
