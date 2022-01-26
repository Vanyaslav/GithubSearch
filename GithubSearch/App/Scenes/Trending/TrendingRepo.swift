//
//  TrendingRepo.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import RxSwift

class TrendingRepo {
    class Context {
        let showDetail = PublishSubject<TrendingRepoListViewModel.StandardItem>()
        let showError = PublishSubject<String>()
        let disposeFlow = PublishSubject<Void>()
    }
}
