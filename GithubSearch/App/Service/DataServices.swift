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
                                  itemsPerPage: UInt,
                                  date: String,
                                  stars: UInt,
                                  order: ComparisonResult) -> Observable<RepositoriesResponse>
    
    func searchRepositories(with text: String,
                            page: UInt,
                            perPage: UInt) -> Observable<RepositoriesResponse>

    func searchCode(with text: String,
                    prefix: String,
                    page: UInt,
                    perPage: UInt,
                    date: String,
                    order: ComparisonResult) -> Observable<SearchCodeResponse>
}

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
