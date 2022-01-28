//
//  TrendingRepoListViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation

extension Array where Element == Repository {
    var trendingResults: [TrendingRepoListViewModel.StandardItem] {
        map(TrendingRepoListViewModel.StandardItem.init)
    }
}

extension TrendingRepoListViewModel.State {
    enum Action {
        case startLoadingData(id: Void)
        case finishLoadingData(id: Void)
        case process(_ response: RepositoriesResponse)
    }
}
// computed values
extension TrendingRepoListViewModel.State {
    var currentPage: UInt {
        UInt(allItems.count)
    }
    
    var numberOfRecords: UInt {
        UInt(allItems.map { $0.items.count }.reduce(0, +))
    }
    
    var isReloadVisible: Bool {
        numberOfRecords < 7
    }
}

extension TrendingRepoListViewModel {
    struct State {
        var allItems: [SectionModel] = []
        var canReload: Bool = true
        var isLoading: Bool = false
        var failure: GithubService.Error?

        func apply(_ action: Action) -> Self {
            var state = self
            switch action {
            case .startLoadingData:
                state.isLoading = true
                state.failure = nil
            case .finishLoadingData:
                state.isLoading = false
            case .process(.success(let response)):
                let newItems = [SectionModel(model: .standard,
                                             items: (response.items?
                                                        .trendingResults) ?? []) ]
                state.allItems += newItems
                state.canReload = !newItems.isEmpty
                state.failure = newItems.isEmpty
                    ? .allData
                    : nil
            case .process(.failure(let error)):
                state.failure = error
            }
            return state
        }
    }
}
