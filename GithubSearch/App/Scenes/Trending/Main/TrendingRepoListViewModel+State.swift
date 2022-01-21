//
//  TrendingRepoListViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation

extension TrendingRepoListViewModel {
    struct State {
        var currentPage: UInt { UInt(allItems
                                        .map { $0.items.count }
                                        .reduce(0, +)) }

        private(set) var allItems: [SectionModel] = []
        private(set) var canReload: Bool = true
        private(set) var isLoading: Bool = false

        enum Action {
            case startLoadingData(id: Void)
            case finishLoadingData(id: Void)
            case add(_ response: RepositoryListResponse)
        }

        func apply(_ action: Action) -> Self {
            var state = self
            switch action {
            case .startLoadingData:
                state.isLoading = true
            case .finishLoadingData:
                state.isLoading = false
            case .add(let response):
                let newItems = [SectionModel(model: .standard,
                                             items: (response
                                                        .items?
                                                        .compactMap { StandardItem(with: $0) })!)]
                state.allItems += newItems
                state.canReload = response.incomplete_results
            }
            return state
        }
    }
}
