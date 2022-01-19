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

extension TrendingRepoListViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset

        let y = offset.y + bounds.size.height - inset.bottom
        let height = size.height

        if y > height - 50 {
            viewModel.loadData.onNext(())
        }
    }
}

class TrendingRepoListViewController: UIViewController, UITableViewDelegate {
    private let disposeBag = DisposeBag()

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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.standardCellId, for: indexPath) as? TrendingRepoListTableViewCell
            else { return UITableViewCell() }
            cell.set(with: item)
            return cell
        })

        viewModel.loadItems
            .drive(table.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        table.rx.modelSelected(TrendingRepoListViewModel.StandardItem.self)
            .bind(to: viewModel.selectedItem)
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

        // navigationController?.cleanBar()
        view.backgroundColor = UIColor.background
        // navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // moving back in navigation
        if isMovingFromParent {
            viewModel.viewDidUnload.onNext(())
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

        viewModel.loadData.onNext(())
    }
}
