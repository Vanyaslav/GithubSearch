//
//  TrendingRepoListViewModel.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import Foundation
import RxCocoa
import RxSwift
import RxSwiftExt
import Differentiator

extension TrendingRepoListViewModel {
    struct StandardItem: Equatable {
        let id: String
        let title: String
        let subTitle: String?
        let datum: String?

        init(with itemResponse: RepositoryResponse) {
            id = String(itemResponse.id)
            title = itemResponse.name
            subTitle = itemResponse.description
            datum = itemResponse.updated_at
        }

        init(id: String, title: String, subTitle: String? = nil, datum: String? = nil) {
            self.id = id
            self.title = title
            self.subTitle = subTitle
            self.datum = datum
        }
    }
}

extension TrendingRepoListViewModel {
    typealias SectionModel = Differentiator.SectionModel<SectionType, StandardItem>

    enum SectionType: Int {
        case standard
        var identity: Int { rawValue }
    }
}

class TrendingRepoListViewModel {
    private let disposeBag = DisposeBag()
    // in
    let loadData = PublishSubject<Void>()
    let viewDidUnload = PublishSubject<Void>()
    let selectedItem = PublishSubject<StandardItem>()
    // out
    let isLoading: Driver<Bool>
    let loadItems: Driver<[SectionModel]>
    // inner
    private static var currentPage: UInt = 0
    private static var canReload: Bool = true

    init(with context: TrendingRepoContext,
         service: DataServices = GithubService()) {

        let request = loadData
            .filter { Self.canReload }
            .map { (Self.currentPage,
                    AppDefaults.numberOfRepositories,
                    Date.calculateSpecificDate()) }
            .flatMapLatest(service.loadTrendingRepositories)
            .share()
        
        let startLoading = loadData
            .filter { Self.canReload }
            .map(State.Action.startLoadingData)
        
        let stopLoading = request
            .map { _ in }
            .map(State.Action.finishLoadingData)
        
        let elements = request
            .materialize()
            .elements()
            .map(State.Action.add)

        let state = Observable
            .merge(elements, startLoading, stopLoading)
            .scan(State()) { state, action in
                 state.apply(action)
            }

        loadItems = state.map { $0.allItems }.asDriver()
        isLoading = state.map { $0.isLoading }.asDriver()
        
        state.map { Self.currentPage = $0.currentPage }
            .subscribe()
            .disposed(by: disposeBag)
        
        state.map { Self.canReload = $0.canReload }
            .subscribe()
            .disposed(by: disposeBag)

        selectedItem
            .bind(to: context.showDetail)
            .disposed(by: disposeBag)

        request
            .materialize()
            .errors()
            .bind(to: context.showError)
            .disposed(by: disposeBag)

        viewDidUnload
            .bind(to: context.disposeFlow)
            .disposed(by: disposeBag)
    }
}
