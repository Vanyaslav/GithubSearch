//
//  GithubService+Actions.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation
import RxSwift

extension GithubService {
    var securityType: ApiAccessType { AppDefaults.securityType }
    
    func manageRequest(with components: URLComponents) -> Observable<RepositoriesResponse> {
        switch securityType {
        case .authenticated:
            return process(request: authorizedRequest(with: components))
        case .unauthenticated:
            return process(request: unauthorizedRequest(with: components))
        }
    }
}

extension GithubService: DataServices {
    func loadTrendingRepositories(with page: UInt,
                                  pageOffset: UInt,
                                  date: String,
                                  stars: UInt,
                                  order: ComparisonResult = .orderedDescending) -> Observable<RepositoriesResponse> {
        var urlComponents = searchRepositoriesUrlComponents
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: "created:>\(date)"))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.sort,
                                                      value: "stars:>\(stars)"))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.order,
                                                      value: order.param))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.perPage,
                                                      value: String(pageOffset)))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.page,
                                                      value: String(page)))
        return manageRequest(with: urlComponents)
    }
    
    func searchRepositories(with text: String,
                            page: UInt) -> Observable<RepositoriesResponse> {
        var urlComponents = searchRepositoriesUrlComponents
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: text))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.page,
                                                      value: String(page)))
        return manageRequest(with: urlComponents)
    }
}
