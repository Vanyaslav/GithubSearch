//
//  TrendingListTest.swift
//  GithubSearchTests
//
//  Created by Tomas Baculák on 07/01/2022.
//

import XCTest
import RxTest
import RxSwift
@testable import GithubSearch

class TrendingListTest: XCTestCase {
    var scheduler: TestScheduler!
    var context: TrendingRepo.Context!
    var viewModel: TrendingRepoListViewModel!
    var disposeBag: DisposeBag!
    var mockDependency: AppDefaults.Dependency!

    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.context = TrendingRepo.Context()
        self.mockDependency = AppDefaults.Dependency(service: GithubMockService())
        self.viewModel = TrendingRepoListViewModel(with: context!,
                                                   dependency: mockDependency)
        
    }

    func testDataConversion() throws {
        let expectedOutput: [TrendingRepoListViewModel.SectionModel] =
        [TrendingRepoListViewModel.SectionModel(model: .standard,
                                                items: [TrendingRepoListViewModel.SectionModel.Item(id: "44838949",
                                                                                                    title: "swift",
                                                                                                    subTitle: "The Swift Programming Language")
                                                      ]
                                               )]

       let outputs = scheduler.createObserver([TrendingRepoListViewModel.SectionModel].self)

        scheduler.createColdObservable([.next(10, ())])
            .bind(to: viewModel.loadData)
            .disposed(by: disposeBag)

        viewModel.loadItems
            .drive(outputs)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(outputs.events, [.next(10, expectedOutput)])
    }
}
