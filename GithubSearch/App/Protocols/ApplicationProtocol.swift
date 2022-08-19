//
//  ApplicationProtocol.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import UIKit

protocol ApplicationProtocol {
    var app: UIApplication { get }
    var rootViewController: UIViewController? { get }

    func showWebLink(with link: String)
}

extension ApplicationProtocol {
    var app: UIApplication { .shared }

    var rootViewController: UIViewController? {
        app.windows.first?.rootViewController
    }

    func showWebLink(with link: String) {
        guard let url = URL(string: link),
              app.canOpenURL(url) else { return }
        app.open(url)
    }
}
