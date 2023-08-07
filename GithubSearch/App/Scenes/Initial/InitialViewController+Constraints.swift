//
//  InitialViewController+Constraints.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/08/2023.
//

import UIKit

extension InitialViewController {
    var mainButtonHeight: CGFloat { 48 }
    
    var mainWebConstraints: [NSLayoutConstraint] {
        [
            mainWebSiteButton.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                            constant: 4),
            mainWebSiteButton.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -16)
        ]
    }
    
    var mainSymbolViewConstraints: [NSLayoutConstraint] {
        [
            mainSymbolView.topAnchor
                .constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                            constant: 0),
            mainSymbolView.widthAnchor
                .constraint(equalToConstant: 100),
            mainSymbolView.heightAnchor
                .constraint(equalToConstant: 80),
            mainSymbolView.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    var mainTitleLabelConstraints: [NSLayoutConstraint] {
        [
            mainTitleLabel.topAnchor
                .constraint(equalTo: mainSymbolView.bottomAnchor,
                            constant: 20),
            mainTitleLabel.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            mainTitleLabel.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 46),
            mainTitleLabel.centerYAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                            constant: -70)
        ]
    }
    
    var descriptionLabelConstraints: [NSLayoutConstraint] {
        [
            descriptionLabel.topAnchor
                .constraint(equalTo: mainTitleLabel.bottomAnchor,
                            constant: 26),
            descriptionLabel.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            descriptionLabel.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 30)
        ]
    }
    
    var enterAppButtonConstraints: [NSLayoutConstraint] {
        [
            enterAppButton.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                            constant: -48),
            enterAppButton.widthAnchor
                .constraint(equalToConstant: 255),
            enterAppButton.heightAnchor
                .constraint(equalToConstant: mainButtonHeight),
            enterAppButton.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
        
    var bottomInfoViewConstraints: [NSLayoutConstraint] {
        [
            bottomInfoView.centerXAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            bottomInfoView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                            constant: -8)
        ]
    }
}
