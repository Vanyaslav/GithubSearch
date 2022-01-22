//
//  SearchRepoViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 22/01/2022.
//

import UIKit

class SearchRepoViewModel {
    
}

class SearchRepoViewController: UIViewController {
    private lazy var searchTextBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private lazy var searchResultsTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
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
