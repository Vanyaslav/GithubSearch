//
//  TrendingRepoListTableViewCell.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 08/01/2022.
//

import UIKit

class TrendingRepoListTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
    }

    func set(with data: TrendingRepoListViewModel.StandardItem) {
        titleLabel.text = data.title
        descriptionLabel.text = data.subTitle
        dateLabel.text = data.datum
    }
}
