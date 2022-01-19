//
//  Observable+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation

import RxSwift
import RxCocoa

extension Observable {
    func asDriver() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .empty())
    }
}
