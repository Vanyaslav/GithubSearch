//
//  SearchCodeViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation

extension Array where Element == Repository {
    var searchCodeResults:  [SearchCodeViewModel.RepositoryData] {
        map { SearchCodeViewModel
            .RepositoryData(name: $0.name, url: URL(string: $0.url)!)
        }
    }
}

extension SearchCodeViewModel {
    struct StateData: Equatable {
        let search: String
        let page: UInt
    }
}

extension SearchCodeViewModel {
    enum Event {
        case searchChanged(String)
        case response(RepositoriesResponse)
        case scrollingNearBottom
    }
}

extension SearchCodeViewModel {
    struct State {
        var search: String
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

extension SearchCodeViewModel.State {
    static var empty: Self {
        Self(search: "", shouldLoadNextPage: false, results: [], lastError: nil, recentPage: 0, canReload: true)
    }

    static func reduce(state: Self,
                       event: SearchCodeViewModel.Event) -> Self {
        var result = state
        switch event {
        case .searchChanged(let text):
            result.search = text
            result.results = []
        case .scrollingNearBottom:
            return loadNextPage(state: state)
        case .response(.success(let response)):
            return manage(state: state, data: response)
        case .response(.failure(let error)):
            return manage(state: state, failure: error)
        }
        return result
    }
    
    private static func loadNextPage(state: Self) -> Self {
        guard !state.shouldLoadNextPage, state.canReload else {
            return state
        }
        return Self(search: state.search,
                    shouldLoadNextPage: true,
                    results: state.results,
                    lastError: state.lastError,
                    recentPage: state.recentPage,
                    canReload: state.canReload)
        }
    
    private static func manage(state: Self, data: RepositoryListResponse) -> Self {
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
