//
//  GithubMockService.swift
//  GithubSearchTests
//
//  Created by Tomas Baculák on 09/01/2022.
//

import Foundation
import RxSwift

@testable import GithubSearch

class GithubMockService: DataServices {
    var securityType: ApiAccessType { .unauthenticated }
    
    public func loadTrendingRepositories(with page: UInt,
                                         itemsPerPage pageOffset: UInt = 0,
                                         date: String = "",
                                         stars: UInt = 0,
                                         order: ComparisonResult = .orderedDescending) -> Observable<RepositoriesResponse> {
        Observable.create { observer in
            let file = Bundle(for: GithubMockService.self).path(forResource: "GithubMockData", ofType: "json")!
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: file), options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode(RepositoryListResponse.self, from: data)
                observer.onNext(.success(response))
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create { }
        }
    }
    
    func searchRepositories(with text: String,
                            page: UInt,
                            perPage: UInt) -> Observable<RepositoriesResponse> {
        Observable.create { observer in
            let file = Bundle(for: GithubMockService.self).path(forResource: "GithubMockData", ofType: "json")!
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: file), options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode(RepositoryListResponse.self, from: data)
                observer.onNext(.success(response))
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create { }
        }
    }
}
