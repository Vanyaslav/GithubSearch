//
//  InitialViewController+LoadView.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/08/2023.
//

import UIKit

extension InitialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UIDevice.includesSafeArea {
            navigationController?.isNavigationBarHidden = true
        }
        
        navigationController?.cleanBar()
        view.backgroundColor = UIColor.background
    }
    
    override func loadView() {
        super.loadView()

        [
            mainWebSiteButton,
            mainSymbolView,
            mainTitleLabel,
            descriptionLabel,
            enterAppButton,
            bottomInfoView
        ]
            .forEach(view.addSubview)

        NSLayoutConstraint.activate([
            mainWebContraints,
            mainSymbolViewContraints,
            mainTitleLabelContraints,
            descriptionLabelContraints,
            enterAppButtonContraints,
            bottomInfoViewContraints
        ]
            .flatMap { $0 })
    }
}
