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
    
    func manageRequest<T: Decodable>(with components: URLComponents) -> Observable<Result<T, GithubService.Error>> {
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
                                  itemsPerPage: UInt,
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
                                                      value: String(itemsPerPage)))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.page,
                                                      value: String(page)))
        return manageRequest(with: urlComponents)
    }
    
    func searchRepositories(with text: String,
                            page: UInt,
                            perPage: UInt) -> Observable<RepositoriesResponse> {
        var urlComponents = searchRepositoriesUrlComponents
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: text))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.page,
                                                      value: String(page)))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.perPage,
                                                      value: String(perPage)))
        return manageRequest(with: urlComponents)
    }

    func searchCode(with text: String,
                    prefix: String,
                    page: UInt,
                    perPage: UInt,
                    date: String,
                    order: ComparisonResult = .orderedDescending) -> Observable<SearchCodeResponse> {
        var urlComponents = searchCodeUrlComponents
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: String(prefix)))
        urlComponents.queryItems!.append(URLQueryItem(name: QueryItems.query,
                                                      value: text))

        return manageRequest(with: urlComponents)
    }
}
