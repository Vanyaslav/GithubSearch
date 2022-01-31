//
//  MenuViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 28/01/2022.
//

import UIKit
import RxSwift
import RxCocoa

class MenuContext {
    let selectedItem = PublishSubject<Int>()
}

class MenuViewModel {
    private let disposeBag = DisposeBag()
    // in
    let viewLoaded = PublishSubject<Void>()
    let selectedItem = PublishSubject<IndexPath>()
    // out
    let loadItems: Driver<[String]>
    
    init(with context: MenuContext,
         items: [String] = AppType.FlowType.titles ) {
        
        loadItems = viewLoaded
            .map { items }
            .asDriver()
        
        selectedItem
            .map { $0.row }
            .bind(to: context.selectedItem)
            .disposed(by: disposeBag)
    }
}

class MenuViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        let configureCell = { (tableView: UITableView,
                               row: Int,
                               repository: String) -> UITableViewCell in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuCell")
            cell.textLabel?.text = repository
            return cell
        }

        viewModel.loadItems
            .drive(table.rx.items)(configureCell)
            .disposed(by: disposeBag)
        
        table.rx.itemSelected
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        
        return table
    }()
    
    private let viewModel: MenuViewModel
    
    init(with viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuViewController {
    override func loadView() {
        super.loadView()
        
        [tableView]
            .forEach(view.addSubview)
        
        let viewSafeLayout = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor
                .constraint(equalTo: viewSafeLayout.topAnchor),
            tableView.leadingAnchor
                .constraint(equalTo: viewSafeLayout.leadingAnchor),
            tableView.centerXAnchor
                .constraint(equalTo: viewSafeLayout.centerXAnchor),
            tableView.bottomAnchor
                .constraint(equalTo: view.bottomAnchor)
        ])
        
        viewModel.viewLoaded.onNext(())
    }
}
