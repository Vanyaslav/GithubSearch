//
//  GithubService+Actions.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation
import RxSwift

extension GithubService: DataServices {
    func loadTrendingRepositories(with page: UInt,
                                  pageOffset: UInt,
                                  date: String) -> Observable<RepositoryListResponse> {
        var urlComponents = searchRepositoriesUrlComponents
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: "created:>\(date)"))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.sort,
                                                      value: "stars:>1000"))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.order,
                                                      value: ComparisonResult.orderedDescending.param))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.perPage,
                                                      value: String(pageOffset)))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.page,
                                                      value: String(page)))
        return process(request: authorizedRequest(with: urlComponents))
    }
}
