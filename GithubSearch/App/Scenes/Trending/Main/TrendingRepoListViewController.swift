//
//  TrendingRepoListViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift
import RxDataSources

extension TrendingRepoListViewController {
    static var standardCellId: String { "TrendingRepoListTableViewCell" }
}

class TrendingRepoListViewController: UIViewController, UITableViewDelegate {
    private let disposeBag = DisposeBag()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        viewModel.dataInfo
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        return label
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reload", for: .normal)
        button.rx.tap
            .bind(to: viewModel.reloadPressed)
            .disposed(by: disposeBag)
        
        viewModel.isReloadVisible
            .map { !$0 }
            .drive(button.rx.isHidden)
            .disposed(by: disposeBag)
        
        return button
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
        view.color = UIColor.initButton
        viewModel.isLoading
            .drive(view.rx.isAnimating)
            .disposed(by: disposeBag)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.tableFooterView = activityIndicatorView
        table.register(UINib(nibName: "TrendingRepoListTableViewCell", bundle: nil),
                       forCellReuseIdentifier: Self.standardCellId)

        let dataSource = RxTableViewSectionedReloadDataSource<TrendingRepoListViewModel.SectionModel>(configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.standardCellId,
                                                     for: indexPath) as? TrendingRepoListTableViewCell
            cell?.set(with: item)
            return cell ?? UITableViewCell()
        })

        viewModel.loadItems
            .drive(table.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        table.rx.modelSelected(TrendingRepoListViewModel.StandardItem.self)
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        
        table.rx.reachedBottom()
            .bind(to: viewModel.loadData)
            .disposed(by: disposeBag)
        
        viewModel.scrollToFit
            .map(table.scrollToBottom)
            .drive()
            .disposed(by: disposeBag)

        return table
    }()

    private let viewModel: TrendingRepoListViewModel

    init(with viewModel: TrendingRepoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.cleanBar()
        view.backgroundColor = UIColor.background
        // navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        
        navigationItem.titleView = infoLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // moving back in navigation
        if isMovingFromParent {
            viewModel.viewWillUnload.onNext(())
        }
    }
}

extension TrendingRepoListViewController {
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
    }
}
