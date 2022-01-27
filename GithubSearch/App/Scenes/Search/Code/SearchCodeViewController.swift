//
//  SearchCodeViewController.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation
import UIKit

class SearchCodeViewController: UIViewController {
    private let viewModel: SearchCodeViewModel
    
    init(with viewModel: SearchCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
