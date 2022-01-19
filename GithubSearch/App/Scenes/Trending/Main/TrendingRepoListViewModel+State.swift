//
//  TrendingRepoListViewModel+State.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation

extension TrendingRepoListViewModel {
    struct State {
        var currentPage: UInt { UInt(allItems.count) }

        private(set) var allItems: [SectionModel] = []
        private(set) var canReload: Bool = true
        private(set) var isLoading: Bool = false

        enum Action {
            case startLoadData
            case didFinishLoadData
            case add(_ data: (items: [SectionModel], page: UInt, reload: Bool))
        }

        func apply(_ action: Action) -> Self {
            var state = self
            switch action {
            case .startLoadData:
                state.isLoading = true
            case .didFinishLoadData:
                state.isLoading = false
            case .add(let data):
                state.allItems += data.items
                state.canReload = data.reload
            }
            return state
        }
    }
}
