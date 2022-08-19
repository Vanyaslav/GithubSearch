//
//  UIView+Animation.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import UIKit
import RxSwift

extension Reactive where Base == UIButton {
    func whirlpoolAnimation(with duration: TimeInterval) -> Observable<Void> {
            Observable.create { (observer) -> Disposable in
                UIView.animate(withDuration: duration, animations: {
                    self.base.transform = self.base.transform.scaledBy(x: 0.01, y: 0.01)
                    self.base.transform = self.base.transform.rotated(by: .pi)
                }, completion: { _ in
                    observer.onNext(())
                    observer.onCompleted()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { 
                        self.base.transform = .identity
                    }
                })
                return Disposables.create()
            }
        }
}
