//
//  SearchCodeViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation

extension Array where Element == SearchCode {
    var searchCodeResults:  [SearchCodeViewModel.RepositoryData] {
        map { SearchCodeViewModel
                .RepositoryData(name: $0.repository.name, url: URL(string: $0.url)!)
        }
    }
}

extension SearchCodeViewModel {
    struct StateApiData: Equatable {
        let search: String
        let page: UInt
    }
}

extension SearchCodeViewModel {
    enum Event {
        case searchChanged(String)
        case response(SearchCodeResponse)
        case scrollingNearBottom
    }
}

extension SearchCodeViewModel {
    struct State {
        let search: String
        let shouldLoadNextPage: Bool
        let results: [RepositoryData]
        let lastError: GithubService.Error?
        let recentPage: UInt
        let canReload: Bool
        
        var data: StateApiData? {
            shouldLoadNextPage
                ? .init(search: search, page: recentPage)
                : nil
        }
    }
}

extension SearchCodeViewModel.State {
    static var empty: Self {
        Self(search: "", shouldLoadNextPage: false, results: [], lastError: nil, recentPage: 0, canReload: true)
    }

    static func reduce(state: Self,
                       event: SearchCodeViewModel.Event) -> Self {
        switch event {
        case .searchChanged(let text):
            return searchAction(state: state, search: text)
        case .scrollingNearBottom:
            return loadNextPage(state: state)
        case .response(.success(let response)):
            return manage(state: state, data: response)
        case .response(.failure(let error)):
            return manage(state: state, failure: error)
        }
    }
}

extension SearchCodeViewModel.State {
    private static func searchAction(state: Self, search: String) -> Self {
        return Self(search: search,
                    shouldLoadNextPage: !search.isEmpty,
                    results: [],
                    lastError: nil,
                    recentPage: state.recentPage,
                    canReload: state.canReload)
    }
    
    private static func loadNextPage(state: Self) -> Self {
        guard !state.shouldLoadNextPage, state.canReload else {
            return state
        }
        return Self(search: state.search,
                    shouldLoadNextPage: state.canReload,
                    results: state.results,
                    lastError: state.lastError,
                    recentPage: state.recentPage,
                    canReload: state.canReload)
        }
    
    private static func manage(state: Self, data: SearchCodeListResponse) -> Self {
        let itemsToAdd = data.items?.searchCodeResults ?? []
        return Self(search: state.search,
                    shouldLoadNextPage: false,
                    results: (state.results + itemsToAdd),
                    lastError: itemsToAdd.isEmpty
                        ? .allData
                        : nil,
                    recentPage: state.recentPage + 1,
                    canReload: !itemsToAdd.isEmpty)
    }
    
    private static func manage(state: Self, failure: GithubService.Error) -> Self {
        return Self(search: state.search,
                    shouldLoadNextPage: false,
                    results: state.results,
                    lastError: failure,
                    recentPage: state.recentPage,
                    canReload: state.canReload)
    }
}
