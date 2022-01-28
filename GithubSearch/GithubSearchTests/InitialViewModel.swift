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
        viewModel.navigateToMain.onNext(())

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.mainWebSite) }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelTerms() throws {
        viewModel.navigateToInfo.onNext(())

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.infoSite) }
            .disposed(by: disposeBag!)
    }

    func testInitialViewModelCompanyWebSite() throws {
        viewModel.navigateToDocs.onNext(())

        context.showWebSite
            .bind { XCTAssertEqual($0, InitialViewModel.Linx.docsSite) }
            .disposed(by: disposeBag!)
    }
}
