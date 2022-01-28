//
//  SearchCodeViewModel.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation
import RxCocoa
import RxSwift
import RxFeedback

extension SearchCodeViewModel {
    // Input data for API request
    enum requestInputs {
        // number of trending repositories taken by pagination in the table (TrendingRepoListViewController) / (max 100)
        static let resultsPerPage: UInt = 100
        // example: value 7 will set the start date a week before today
        static let date: String = Date.calculateSpecificDate(with: 200)
        //
        static let dataOrder: ComparisonResult = .orderedDescending
        //
        static let defaultSearch = "org:apple"
        //
        static let defaultRepoSearch = "repo:apple/swift"
        //
        static let defaultUserSearch = "user:"
    }
}

extension SearchCodeViewModel.RepositoryData: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(name) | \(url)"
    }
}

extension SearchCodeViewModel {
    struct RepositoryData: Equatable {
        let name: String
        let url: URL
    }
}

class SearchCodeViewModel {
    private let disposeBag = DisposeBag()
    // in
    let scrolledBottom = PublishSubject<Void>()
    let searchInputs = PublishSubject<String>()
    // out
    let infoDescription = BehaviorRelay<String>(value: "")
    let loadItems = BehaviorRelay<[RepositoryData]> (value: [])
    
    init(with dependency: AppDefaults.Dependency,
         context: SearchCodeContext) {
        
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
                    .bind(to: context.showError),
                state.map { $0.results }
                    .drive(me.loadItems),
                state.map { $0.search }
                    .map { requestInputs.defaultRepoSearch + " " + requestInputs.defaultUserSearch + $0 }
                    .drive(me.infoDescription)
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
                          dependency.service.searchCode(with: requestInputs.defaultUserSearch + resource.search,
                                                        prefix: requestInputs.defaultRepoSearch,
                                                        page: resource.page,
                                                        perPage: requestInputs.resultsPerPage,
                                                        date: requestInputs.date,
                                                        order: requestInputs.dataOrder)
                              .asSignal(onErrorJustReturn: .failure(.generic))
                              .map(Event.response)
                      }))
            .drive()
            .disposed(by: disposeBag)
    }
}
