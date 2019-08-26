//
//  Formatter+Helpers.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/24/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

extension Formatter {
    static func changeDateForLocationTimeZone(for seconds: Int) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: seconds)
        formatter.dateFormat = "YYYY-MMM-dd, HH:mm"
        return formatter.string(from: date)
    }
}
