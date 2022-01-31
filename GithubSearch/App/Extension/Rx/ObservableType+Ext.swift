//
//  ObservableType+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 31/01/2022.
//

import RxSwift

extension ObservableType {
    func withPrevious() -> Observable<(Element?, Element)> {
    return scan([], accumulator: { (previous, current) in
        Array(previous + [current]).suffix(2)
      })
    .map { arr -> (previous: Element?, current: Element) in
        (arr.count > 1
        ? arr.first
        : nil,
        arr.last!)
      }
  }
}
