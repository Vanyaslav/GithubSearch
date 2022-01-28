//
//  SearchRepoViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

class SearchRepoViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var searchTextBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.rx.text
            .throttle(RxTimeInterval.milliseconds(500),
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
                               repository: SearchRepoViewModel.RepositoryData) -> UITableViewCell in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RepositoryCell")
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url.description
            return cell
        }
        
        viewModel.loadItems
            .asDriver()
            .drive(table.rx.items)(configureCell)
            .disposed(by: disposeBag)
        
        table.rx.reachedBottom()
            .skip(1)
            .bind(to: viewModel.scrolledBottom)
            .disposed(by: disposeBag)
        
        return table
    }()
    
    private let viewModel: SearchRepoViewModel
    
    init(with viewModel: SearchRepoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchRepoViewController {
    override func loadView() {
        super.loadView()

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
