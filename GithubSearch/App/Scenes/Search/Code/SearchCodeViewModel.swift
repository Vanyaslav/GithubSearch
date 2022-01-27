//
//  SearchCodeViewModel.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 27/01/2022.
//

import Foundation

extension SearchCodeViewModel {
    // Input data for API request
    enum requestInputs {
        // number of trending repositories taken by pagination in the table (TrendingRepoListViewController) / (max 100)
        static let resultsPerPage: UInt = 100
    }
}

extension SearchCodeViewModel.RepositoryData: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(name) | \(url)"
    }
}

extension SearchCodeViewModel {
    struct RepositoryData: Equatable {
        let name: String
        let url: URL
    }
}

class SearchCodeViewModel {
    init(with dependency: AppDefaults.Dependency,
         context: SearchCodeContext) {
        
    }
}
