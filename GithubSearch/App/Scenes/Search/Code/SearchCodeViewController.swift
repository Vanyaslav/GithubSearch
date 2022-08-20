//
//  SearchCodeViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation
import UIKit
import RxSwift

class SearchCodeViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        viewModel.infoDescription
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        return label
    }()

    private lazy var searchTextBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.rx.text
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .unwrap()
            .bind(to: viewModel.searchInputs)
            .disposed(by: disposeBag)
        return bar
    }()

    private lazy var searchResultsTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false

        let configureCell = { (tableView: UITableView,
                               row: Int,
                               repository: SearchCodeViewModel.RepositoryData) -> UITableViewCell in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RepositoryCell")
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.subTitle
            return cell
        }

        viewModel.loadItems
            .drive(table.rx.items)(configureCell)
            .disposed(by: disposeBag)

        table.rx.reachedBottom()
            .skip(1)
            .bind(to: viewModel.scrolledBottom)
            .disposed(by: disposeBag)

        return table
    }()

    private let viewModel: SearchCodeViewModel

    init(with viewModel: SearchCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // moving back in navigation
        if isMovingFromParent {
            viewModel.viewWillUnload.onNext(())
        }
    }
}

extension SearchCodeViewController {
    override func loadView() {
        super.loadView()
        
        navigationItem.titleView = infoLabel

        navigationController?.cleanBar()
        view.backgroundColor = UIColor.background

        [searchTextBar, searchResultsTable]
            .forEach(view.addSubview)

        let viewSafeLayout = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            searchTextBar.topAnchor
                .constraint(equalTo: viewSafeLayout.topAnchor),
            searchTextBar.leadingAnchor
                .constraint(equalTo: viewSafeLayout.leadingAnchor),
            searchTextBar.centerXAnchor
                .constraint(equalTo: viewSafeLayout.centerXAnchor),

            searchResultsTable.topAnchor
                .constraint(equalTo: searchTextBar.bottomAnchor),
            searchResultsTable.leadingAnchor
                .constraint(equalTo: viewSafeLayout.leadingAnchor),
            searchResultsTable.centerXAnchor
                .constraint(equalTo: viewSafeLayout.centerXAnchor),
            searchResultsTable.bottomAnchor
                .constraint(equalTo: viewSafeLayout.bottomAnchor)
        ])
    }
}
