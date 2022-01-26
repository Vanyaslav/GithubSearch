//
//  DataServices.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation
import RxSwift

protocol DataServices {
    var securityType: ApiAccessType { get }
    
    func loadTrendingRepositories(with page: UInt,
                                  pageOffset: UInt,
                                  date: String,
                                  stars: UInt,
                                  order: ComparisonResult) -> Observable<RepositoriesResponse>
}

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
