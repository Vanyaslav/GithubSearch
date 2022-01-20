//
//  TrendingRepoDetailViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/01/2022.
//

import Foundation
import UIKit

class TrendingRepoDetailViewModel {
    let description: String
    let title: String

    init(with data: TrendingRepoListViewModel.StandardItem) {
        title = data.title
        description = data.subTitle ?? ""
    }
}

class TrendingRepoDetailViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 150)
        label.numberOfLines = 0
        label.text = viewModel.title
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 100)
        label.numberOfLines = 0
        label.text = viewModel.description
        return label
    }()

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 12
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

        let viewSafeLayout = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor
                .constraint(equalTo: viewSafeLayout.topAnchor),
            scrollView.leadingAnchor
                .constraint(equalTo: viewSafeLayout.leadingAnchor),
            scrollView.centerXAnchor
                .constraint(equalTo: viewSafeLayout.centerXAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: viewSafeLayout.bottomAnchor)
        ])
    }
}
