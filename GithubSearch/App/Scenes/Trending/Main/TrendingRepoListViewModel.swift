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
    // Input data for API request
    enum requestInputs {
        // example: value 7 will set the start date a week before today
        static let date: String = Date.calculateSpecificDate(with: 200)
        // number of trending repositories taken by pagination in the table (TrendingRepoListViewController) / (max 100)
        static let resultsPerPage: UInt = 10
        static let numberOfStars: UInt = 1000
        static let dataOrder: ComparisonResult = .orderedDescending
    }
}

extension TrendingRepoListViewModel {
    struct StandardItem: Equatable {
        let id: String
        let title: String
        let subTitle: String?
        let datum: String?

        init(with item: Repository) {
            id = String(item.id)
            title = item.name
            subTitle = item.description
            datum = item.updated_at
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
    let viewWillUnload = PublishSubject<Void>()
    let selectedItem = PublishSubject<StandardItem>()
    let reloadPressed = PublishSubject<Void>()
    let currentPage = BehaviorRelay<UInt>(value: 0)
    // out
    let isLoading: Driver<Bool>
    let loadItems: Driver<[SectionModel]>
    let dataInfo: Driver<String>
    let scrollToFit: Driver<Void>
    let isReloadVisible: Driver<Bool>
    // inner
    private let isDataAvailble = BehaviorRelay<Bool>(value: true)

    init(with context: TrendingRepo.Context,
         service: DataServices = GithubService()) {

        let startLoading = Observable
            .merge(loadData, reloadPressed)
            .withLatestFrom(isDataAvailble)
            .filter { $0 }
            .map { _ in }
        
        let request = startLoading
            .withLatestFrom(currentPage)
            .map { page in
                (page,
                 requestInputs.resultsPerPage,
                 requestInputs.date,
                 requestInputs.numberOfStars,
                 requestInputs.dataOrder)
            }
            .flatMapLatest(service.loadTrendingRepositories)
            .materialize()
            .share()
        
        
        let startLoadingAction = startLoading
            .map(State.Action.startLoadingData)
        
        let stopLoading = request
            .map { _ in }
            .map(State.Action.finishLoadingData)
        
        let elements = request
            .elements()
            .map(State.Action.process)

        let state = Observable
            .merge(elements, startLoadingAction, stopLoading)
            .scan(State()) { state, action in
                 state.apply(action)
            }

        loadItems = state
            .map { $0.allItems }
            .distinctUntilChanged()
            .asDriver()
        
        isLoading = state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver()
        
        dataInfo = state
            .map { "\($0.numberOfRecords) records loaded, page: \($0.currentPage)" }
            .distinctUntilChanged()
            .asDriver()
        
        state
            .map { $0.currentPage }
            .distinctUntilChanged()
            .bind(to: currentPage)
            .disposed(by: disposeBag)
        
        state
            .map{ $0.canReload }
            .distinctUntilChanged()
            .bind(to: isDataAvailble)
            .disposed(by: disposeBag)
        
        let failureMessage = state
            .map { $0.failureTitle }
            .distinctUntilChanged()
            .unwrap()
        
        isReloadVisible = state
            .map { $0.isReloadVisible }
            .distinctUntilChanged()
            .asDriver()

        selectedItem
            .bind(to: context.showDetail)
            .disposed(by: disposeBag)

        let errors = Observable
            .merge(request.errors().map { $0.localizedDescription },
                   failureMessage)
        errors
            .bind(to: context.showError)
            .disposed(by: disposeBag)
        
        scrollToFit = errors.map { _ in }.asDriver()

        viewWillUnload.debug()
            .bind(to: context.disposeFlow)
            .disposed(by: disposeBag)
    }
}
