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
    // probably can be done more fancy way
    private static var currentPage: UInt = 0
    private static var canReload: Bool = true

    init(with context: TrendingListContext,
         service: DataServices = GithubService()) {

        let request = loadData
            .filter { Self.canReload }
            .map { (Self.currentPage, Date.calculateSpecificDate()) }
            .flatMapLatest(service.loadTrendingRepositories)
            .share()

        isLoading = Observable
            .merge(loadData
                    .filter { Self.canReload }
                    .map { _ in true },
                   request
                    .materialize()
                    .map { _ in false })
            .asDriver()

        loadItems = request.enumerated()
            .map { (index, data) -> [SectionModel] in
                Self.currentPage += AppDefaults.numberOfRepositories
                Self.canReload = data.incomplete_results
                return [SectionModel(model: .standard,
                                     items: (data.items?.compactMap { StandardItem(with: $0) })!)]
            }
            .scan([], accumulator: +)
            .asDriver()

//        let state = request.enumerated()
//            .map { (index, data) -> ([SectionModel], UInt, Bool) in
//                ([SectionModel(model: .standard,
//                               items: (data.items?.compactMap { StandardItem(with: $0) })!)],
//                 AppDefaults.numberOfRepositories,
//                 data.incomplete_results)
//            }.map { State.Action.add }
//            .scan(State().apply)
//
//        loadItems = state
//            .map { $0.allItems }
//            .asDriver()

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
