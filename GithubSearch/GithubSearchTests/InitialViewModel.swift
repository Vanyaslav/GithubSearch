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

    func testInitialViewModelPrivacy() throws {
        viewModel.navigateTo.onNext(.mainWebSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.mainWebSite.rawValue) }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelTerms() throws {
        viewModel.navigateTo.onNext(.infoSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.infoSite.rawValue) }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelCompanyWebSite() throws {
        viewModel.navigateTo.onNext(.docsSite)

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.docsSite.rawValue) }
            .disposed(by: disposeBag!)
    }
}
