//
//  SearchRepoViewModel+Model.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 26/01/2022.
//

import Foundation

extension Array where Element == Repository {
    var searchResults:  [SearchRepoViewModel.RepositoryData] {
        map { SearchRepoViewModel
            .RepositoryData(name: $0.name, url: URL(string: $0.url)!)
        }
    }
}

extension SearchRepoViewModel {
    struct StateData: Equatable {
        let search: String
        let page: UInt
    }
}

extension SearchRepoViewModel {
    enum Event {
        case searchChanged(String)
        case response(RepositoriesResponse)
        case scrollingNearBottom
    }
}

extension SearchRepoViewModel {
    struct State {
        var search: String {
            didSet {
                if search.isEmpty {
                    self.shouldLoadNextPage = false
                    self.results = []
                    self.lastError = nil
                    return
                }
                self.shouldLoadNextPage = true
                self.lastError = nil
            }
        }
        
        var shouldLoadNextPage: Bool
        var results: [RepositoryData]
        var lastError: GithubService.Error?
        var recentPage: UInt
        var canReload: Bool
        
        var data: StateData? {
            shouldLoadNextPage
                ? .init(search: search, page: recentPage)
                : nil
        }
    }
}

extension SearchRepoViewModel.State {
    static var empty: Self {
        Self(search: "", shouldLoadNextPage: false, results: [], lastError: nil, recentPage: 0, canReload: true)
    }

    static func reduce(state: Self,
                       event: SearchRepoViewModel.Event) -> Self {
        var result = state
        switch event {
        case .searchChanged(let text):
            result.search = text
            result.results = []
        case .scrollingNearBottom:
            result.shouldLoadNextPage = result.canReload
        case .response(.success(let response)):
            let itemsToAdd = response.items?.searchResults ?? []
            result.results += itemsToAdd
            result.canReload = !itemsToAdd.isEmpty
            result.shouldLoadNextPage = false
            result.lastError = itemsToAdd.isEmpty
                ? .allData
                : nil
            result.recentPage += 1
        case .response(.failure(let error)):
            result.shouldLoadNextPage = false
            result.lastError = error
        }
        return result
    }
}
