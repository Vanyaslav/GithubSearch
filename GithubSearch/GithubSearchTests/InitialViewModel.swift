//
//  InitialViewModelTest.swift
//  GithubSearchTests
//
//  Created by Tomas Baculák on 09/01/2022.
//

import XCTest
import RxSwift
@testable import GithubSearch

class InitialViewModelTest: XCTestCase {
    var context: AppContext!
    var viewModel: InitialViewModel!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.context = AppContext()
        self.viewModel = InitialViewModel(with: context)
    }

    func testInitialViewModelPrivacy() {
        viewModel.navigateTo.onNext(.mainWebSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, "https://github.com") }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelTerms() {
        viewModel.navigateTo.onNext(.infoSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, "https://github.com/about") }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelCompanyWebSite() {
        viewModel.navigateTo.onNext(.docsSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, "https://docs.github.com/en") }
            .disposed(by: disposeBag!)
    }
}
