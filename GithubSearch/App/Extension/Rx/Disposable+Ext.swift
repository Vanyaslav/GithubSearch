//
//  Disposable+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import RxSwift

extension Disposable {
    @discardableResult
    public func disposed(by bag: CompositeDisposable) -> CompositeDisposable.DisposeKey? {
        return bag.insert(self)
    }

    public func asObservable() -> Observable<Void> {
        return .create { _ in
            return self
        }
    }
}
