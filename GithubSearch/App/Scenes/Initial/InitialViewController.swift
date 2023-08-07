//
//  ViewController.swift
//  XapoTest
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit
import RxSwift
import RxCocoa

class InitialViewController: UIViewController {
    private let disposeBag = DisposeBag()

    lazy var mainWebSiteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go to Github", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.rx.tap
            .map { .mainWebSite }
            .bind(to: viewModel.navigateTo)
            .disposed(by: disposeBag)
        return button
    }()

    lazy var mainSymbolView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "Octocat")
        return view
    }()

    lazy var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to iOS Test"
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 36)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "iOS Test \n \n Lorem ipsum dolor sit amet, consectetur, adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna."
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    lazy var enterAppButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Enter the app", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = mainButtonHeight / 2
        button.backgroundColor = UIColor.initButton
        button.rx.tap
            .flatMap { button.rx
                .whirlpoolAnimation(with: InitialViewModel.progressDelay.intervalFromMiliseconds) }
            .bind(to: viewModel.startApp)
            .disposed(by: disposeBag)
        return button
    }()
    
    lazy var bottomInfoView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [privacyButton, andLabel, termsButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()

    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("Help".smallUnderline(), for: .normal)
        button.rx.tap
            .map { .infoSite }
            .bind(to: viewModel.navigateTo)
            .disposed(by: disposeBag)
        return button
    }()

    private lazy var andLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppDefaults.Style.small.color
        label.font = .systemFont(ofSize: 12)
        label.text = "and"
        return label
    }()

    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle("info".smallUnderline(), for: .normal)
        button.rx.tap
            .map { .docsSite }
            .bind(to: viewModel.navigateTo)
            .disposed(by: disposeBag)
        return button
    }()

    private let viewModel: InitialViewModel

    init(with viewModel: InitialViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
