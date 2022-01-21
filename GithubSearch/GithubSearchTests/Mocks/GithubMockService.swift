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
    public func loadTrendingRepositories(with page: UInt,
                                         pageOffset: UInt = 0,
                                         date: String = "") -> Observable<RepositoryListResponse> {
        Observable.create { observer in
            let file = Bundle(for: GithubMockService.self).path(forResource: "GithubMock", ofType: "json")!
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: file), options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode(RepositoryListResponse.self, from: data)
                observer.onNext(response)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create { }
        }
    }
}
