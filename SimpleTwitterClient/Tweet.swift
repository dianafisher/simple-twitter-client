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
    var formattedTimestamp: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var profileImageUrl: URL?
    
    var data: NSDictionary
    
    override var description: String {
        
        let str = "--> user: \(String(describing: user)), text: \(text ?? "no text"), retweetCount: \(retweetCount), favoritesCount: \(favoritesCount))<--"
        return str
    }
    
    init(dictionary: NSDictionary) {
        
        data = dictionary
        
//        print(dictionary)
        
        let userDictionary = dictionary["user"] as? NSDictionary
        if let dict = userDictionary {
            user = User(dictionary: dict)
        } else {
            user = nil
        }
        
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)!
            print(timestamp)
            print(timestamp.timeAgoSinceNow ?? "NONE")
            
            formattedTimestamp = timestamp.timeAgoSinceNow
//            log.info("timestamp: \(timestamp)")
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
    var timeAgoSinceNow: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }
        
        let components = timeString.components(separatedBy: " ")
        let number = components[0]
        let time = components[1]

        print("number: \(number), time: \(time)")
        
        let startIndex = time.startIndex
        let endIndex = time.index(startIndex, offsetBy: 1)
        let c = time.substring(to: endIndex)
        
        print("c: \(c)")
        
        let result = "\(number)\(c)"
        
        print("\(timeString) ago")
        
        return result
    }
}

