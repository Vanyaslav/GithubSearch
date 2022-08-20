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
    struct InputData {
        let user: String
        let repo: String
    }
}

extension SearchCodeViewModel {
    enum SearchType {
        case noInput,
             input(org: String, repo: String)

        init(with org: String? = nil, repo: String? = nil) {
            if let org = org, let repo = repo {
                self = .input(org: org, repo: repo)
            } else {
                self = .noInput
            }
        }
        
        var requestInput: String {
            switch self {
            case .noInput:
                return RequestInputs.defaultRepoSearch
                + RequestInputs.defaultSearch
                
            case .input(org: let org, repo: let repo):
                return RequestInputs.defaultRepoSearch
                + org
                + "/"
                + repo
            }
        }
    }
}

extension SearchCodeViewModel {
    enum RequestInputs {
        static let defaultSearch = "apple/swift"
        static let defaultRepoSearch = "repo:"
        static let defaultUserSearch = "user:"
    }
}

extension SearchCodeViewModel.RepositoryData: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(name) | \(subTitle)"
    }
}

extension SearchCodeViewModel {
    struct RepositoryData: Equatable, Hashable {
        let name: String
        let subTitle: String
    }
}

class SearchCodeViewModel {
    private let disposeBag = DisposeBag()
    // in
    let scrolledBottom = PublishSubject<Void>()
    let searchInputs = PublishSubject<String>()
    let viewWillUnload = PublishSubject<Void>()
    // out
    let infoDescription = BehaviorRelay<String>(value: "")
    let loadItems: Driver<[RepositoryData]>

    private let data = BehaviorRelay<[RepositoryData]> (value: [])
    
    init(with dependency: AppDefaults.Dependency,
         context: SearchCodeContext,
         inputData: InputData? = nil) {

        loadItems = data.asDriver()

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

        let requestInputs = SearchType(with: inputData?.user,
                                       repo: inputData?.repo).requestInput

        let bindUI: (Driver<State>) -> Signal<Event> = bind(self) { me, state in
            let subscriptions = [
                state.map { $0.lastError?.errorDescription }
                    .asObservable()
                    .unwrap()
                    .bind(to: context.showMessage),
                state.map { $0.results }
                    .drive(me.data),
                state.map { $0.search }
                    .map { requestInputs
                        + " "
                        + RequestInputs.defaultUserSearch
                        + $0 }
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
                          dependency.service.searchCode(with: RequestInputs.defaultUserSearch
                                                        + resource.search,
                                                        prefix: requestInputs)
                              .asSignal(onErrorJustReturn: .failure(.generic))
                              .map(Event.response)
                      }))
            .drive()
            .disposed(by: disposeBag)
    }
}
