//
//  AppDefaults.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 07/01/2022.
//

import Foundation
import UIKit

enum ApiAccessType {
    case authenticated, unauthenticated
}

extension AppDefaults {
    struct Dependency {
        let service: DataServices

        init(with service: DataServices = GithubService()) {
            self.service = service
        }
    }
}

struct AppDefaults {
    // you can make up to 30 requests per minute with authenticated requests. For unauthenticated requests, the rate limit allows you to make up to 10 requests per minute.
    static let securityType: ApiAccessType = .unauthenticated
    // in case of using authorized access, the api token needs to be replaced with personal one (XXXXXXXX to be replaced)
    // https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
    static let apiToken = "token XXXXXXXX"
}

protocol UIObjectStyle {
    var color: UIColor { get }
    var fontSize: CGFloat { get }
}

extension AppDefaults {
    // default UI
    enum Style: UIObjectStyle {
        case small

        var color: UIColor {
            return .white
        }
        var fontSize: CGFloat {
            return 12
        }
    }
}
