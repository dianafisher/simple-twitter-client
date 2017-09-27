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


