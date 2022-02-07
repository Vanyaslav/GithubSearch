//
//  SearchRepoViewModel.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 26/01/2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

extension SearchRepoViewModel {
    // Input data for API request
    enum RequestInputs {
        // number of trending repositories taken by pagination in the table (TrendingRepoListViewController) / (max 100)
        static let resultsPerPage: UInt = 15
    }
}

extension SearchRepoViewModel.RepositoryData: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(name) | \(url)"
    }
}

extension SearchRepoViewModel {
    struct RepositoryData: Equatable {
        let name: String
        let url: URL
    }
}

class SearchRepoViewModel {
    private let disposeBag = DisposeBag()
    // in
    let selectedItem = PublishSubject<RepositoryData>()
    let scrolledBottom = PublishSubject<Void>()
    let searchInputs = PublishSubject<String>()
    let viewWillUnload = PublishSubject<Void>()
    // out
    let loadItems: Driver<[RepositoryData]>

    private let data = BehaviorRelay<[RepositoryData]> (value: [])
    
    init(with dependency: AppDefaults.Dependency,
         context: SearchRepoContext) {

        loadItems = data.asDriver()

        selectedItem
            .map { SearchCodeViewModel.InputData(user: "apple", repo: $0.name) }
            .bind(to: context.showCodeSearch)
            .disposed(by: disposeBag)

        viewWillUnload
            .bind(to: context.disposeFlow)
            .disposed(by: disposeBag)
        
        let scrolledBottom = scrolledBottom
    
        let triggerLoadNextPage: (Driver<State>) -> Signal<Event> = { state in
            return state.flatMapLatest { state -> Signal<Event> in
                if state.shouldLoadNextPage {
                    return Signal.empty()
                }
                
                return scrolledBottom
                    .map { _ in Event.scrollingNearBottom }
                    .asSignal(onErrorSignalWith: Signal.empty())
            }
        }

        let bindUI: (Driver<State>) -> Signal<Event> = bind(self) { me, state in
            let subscriptions = [
                state.map { $0.lastError?.errorDescription }
                    .asObservable()
                    .unwrap()
                    .bind(to: context.showMessage),
                state.map { $0.results }
                    .drive(me.data)
            ]

            let events: [Signal<Event>] = [
                me.searchInputs
                    .map(Event.searchChanged)
                    .asSignal(onErrorSignalWith: Signal.empty()),
                triggerLoadNextPage(state)
            ]

            return Bindings(subscriptions: subscriptions, events: events)
        }

        Driver.system(
            initialState: State.empty,
            reduce: State.reduce,
            feedback:
                bindUI,
                react(request: { $0.data },
                      effects: { resource in
                          dependency.service.searchRepositories(with: resource.search,
                                                                page: resource.page,
                                                                perPage: RequestInputs.resultsPerPage)
                              .asSignal(onErrorJustReturn: .failure(.generic))
                              .map(Event.response)
                      }))
            .drive()
            .disposed(by: disposeBag)
    }
}
