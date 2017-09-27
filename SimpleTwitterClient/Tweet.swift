//
//  Tweet.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var user: User?
    var text: String?
    var timestamp: Date
    var timeAgoSinceNowString: String?
    var formattedDateString: String?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var profileImageUrl: URL?
    
    var data: NSDictionary
    
    override var description: String {
        
        let str = "--> user: \(user?.name ?? "none")), text: \(text ?? "no text"), retweetCount: \(retweetCount), favoriteCount: \(favoriteCount))<--"
        return str
    }
    
    init(dictionary: NSDictionary) {
        
        data = dictionary
        
        print(dictionary)
        
        let userDictionary = dictionary["user"] as? NSDictionary
        if let dict = userDictionary {
            user = User(dictionary: dict)
        } else {
            user = nil
        }
        
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        formattedDateString = ""
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)!
            print(timestamp)
            print(timestamp.timeAgoSinceNow)
            
            formatter.dateFormat = "M/d/yy, HH:mm aaa"
            let formatted = formatter.string(from: timestamp)
            
            log.info("formatted: \(formatted)")
            formattedDateString = formatted
            timeAgoSinceNowString = timestamp.timeAgoSinceNow

        } else {
            timestamp = Date()
        }
        
        let profileImageUrlString = dictionary["profile_image_url"] as? String
        if profileImageUrlString != nil {
            profileImageUrl = URL(string: profileImageUrlString!)
        } else {
            profileImageUrl = nil
        }
        
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        // iterate through dictionaries
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
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

