//
//  TrendingRepoDetailViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

class TrendingRepoDetailViewModel {
    // in
    let viewLoaded = PublishSubject<Void>()
    // out
    let description: Driver<String>
    let title: Driver<String>

    init(with data: TrendingRepoListViewModel.StandardItem) {
        title = viewLoaded
            .mapTo(data.title)
            .asDriver()
        
        description = viewLoaded
            .mapTo(data.subTitle ?? "")
            .asDriver()
    }
}

class TrendingRepoDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 150)
        label.numberOfLines = 0
        viewModel.title
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100)
        label.numberOfLines = 100
        label.textColor = .white
        viewModel.description
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        return label
    }()

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 20
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor
                .constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor
                .constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            contentView.widthAnchor
                .constraint(equalTo: view.widthAnchor),
            contentView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor)
        ])

        return view
    }()

    private let viewModel: TrendingRepoDetailViewModel

    init(with viewModel: TrendingRepoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.background
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrendingRepoDetailViewController {
    override func loadView() {
        super.loadView()

        [scrollView]
            .forEach(view.addSubview)

        let offSet: CGFloat = 16
        let viewSafeLayout = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor
                .constraint(equalTo: viewSafeLayout.topAnchor),
            scrollView.leadingAnchor
                .constraint(equalTo: viewSafeLayout.leadingAnchor,
                           constant: offSet),
            scrollView.centerXAnchor
                .constraint(equalTo: viewSafeLayout.centerXAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: viewSafeLayout.bottomAnchor)
        ])
        
        viewModel.viewLoaded.onNext(())
    }
}
