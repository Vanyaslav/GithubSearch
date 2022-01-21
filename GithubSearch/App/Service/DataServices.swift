//
//  DataServices.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import RxSwift

protocol DataServices {
    func loadTrendingRepositories(with page: UInt,
                                  pageOffset: UInt,
                                  date: String) -> Observable<RepositoryListResponse>
}
