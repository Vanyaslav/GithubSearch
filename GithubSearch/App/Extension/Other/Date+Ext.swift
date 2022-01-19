//
//  Date+Ext.swift
//  GithubSearch
//
//  Created by Tomas Baculák on 09/01/2022.
//

import Foundation

extension Date {
    static func calculateSpecificDate(with days: Int = Int(AppDefaults.trendingPeriod)) -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"

        guard let specificDate = NSCalendar.current.date(byAdding: Calendar.Component.day,
                                                         value: -days,
                                                         to: today)
        else { return dateFormatter.string(from: today) }
        return dateFormatter.string(from: specificDate)
    }
}
