//
//  AppType.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 19/08/2022.
//

import Foundation

enum AppType: CaseIterable, Equatable {
    static var allCases: [AppType] = [.tabBar, .menu, .flow(type: .undefined)]
    
    case tabBar,
         menu,
         flow(type: FlowType)
    
    var title: String {
        switch self {
        case .tabBar:
            return "Tab bar"
        case .menu:
            return "Menu"
        case .flow(_):
            return "Flow"
        }
    }
}
