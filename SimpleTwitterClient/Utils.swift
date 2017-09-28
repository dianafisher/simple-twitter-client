//
//  Utils.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/28/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class Utils {
    
    private static let parseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return formatter
    }()
    
    private static let reformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, HH:mm aaa"
        return formatter
    }()
    
    static func dateFromTimestamp(timestamp: String) -> Date {
        let date = parseDateFormatter.date(from: timestamp)!
        return date
    }
    
    static func timeAgoSinceNowString(fromDate: Date) -> String {
        
        return fromDate.timeAgoSinceNow
    }
    
    static func formattedDate(date: Date) -> String {
        
        let formatted = reformatter.string(from: date)
        return formatted
    }
}

extension Date {
    
    // A string to represent date in terms of how long ago it was - e.g. 5m for 5 minutes
    var timeAgoSinceNow: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return ""
        }
        
        let components = timeString.components(separatedBy: " ")
        let number = components[0]
        let time = components[1]
        
        let startIndex = time.startIndex
        let endIndex = time.index(startIndex, offsetBy: 1)
        let c = time.substring(to: endIndex)
        
        let result = "\(number)\(c)"
        
        return result
    }
}


