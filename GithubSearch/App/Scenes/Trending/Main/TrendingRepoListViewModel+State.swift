//
//  TrendingRepoListViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation

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
        private(set) var allItems: [SectionModel] = []
        private(set) var canReload: Bool = true
        private(set) var isLoading: Bool = false
        private(set) var failureTitle: String?

        func apply(_ action: Action) -> Self {
            var state = self
            switch action {
            case .startLoadingData:
                state.isLoading = true
                state.failureTitle = nil
            case .finishLoadingData:
                state.isLoading = false
            case .process(.success(let response)):
                let newItems = [SectionModel(model: .standard,
                                             items: (response
                                                        .items?
                                                        .compactMap { StandardItem(with: $0) })!)]
                state.allItems += newItems
                state.canReload = response.incomplete_results
                state.failureTitle = response.incomplete_results
                    ? nil
                    : "There is no more records with givin criteria."
            case .process(.failure(let error)):
                state.failureTitle = error.errorDescription
            }
            return state
        }
    }
}
