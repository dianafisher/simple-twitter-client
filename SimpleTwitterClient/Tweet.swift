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
    var retweet: Tweet?
    
    var idString: String?
    var text: String?
    var timeAgoSinceNowString: String?
    var formattedDateString: String?
    var quotedCount: Int = 0
    var retweetCount: Int = 0
    var replyCount: Int = 0
    var favoriteCount: Int = 0
    var profileImageUrl: URL?
    var timestamp: Date
    var inReplyToStatusIdString: String?
    var inReplyToUserIdString: String?
    var inReplyToScreenName: String?
    var quotedStatusId: String?
    var hasFavorited: Bool
    var hasRetweeted: Bool
    
    var quotedTweet: Tweet?
    var retweetedTweet: Tweet?
    var mediaUrl: URL?
    
    static let tweetsDidUpdateNotification = "TweetDidUpdate"
    
    override var description: String {
        
        let str = "--> id: \(idString ?? "X"), user: \(user?.name ?? "none")), text: \(text ?? "no text"), retweetCount: \(retweetCount), favoriteCount: \(favoriteCount), hasRetweeted: \(hasRetweeted), hasFavorited: \(hasFavorited))<--"
        return str
    }
    
    init(dictionary: NSDictionary) {
        
        log.verbose(dictionary)
        
        let userDictionary = dictionary["user"] as? NSDictionary
        if let dict = userDictionary {
            user = User(dictionary: dict)
        } else {
            user = nil
        }
        
        text = dictionary["text"] as? String
        
        hasFavorited = (dictionary["favorited"] as? Bool) ?? false
        hasRetweeted = (dictionary["retweeted"] as? Bool) ?? false
        
        idString = dictionary["id_str"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        formattedDateString = ""
        
        let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        if let dict = retweetedStatus {
            retweet = Tweet(dictionary: dict)            
        } else {
            retweet = nil
        }
        
        let timestampString = dictionary["created_at"] as? String
                
        if let timestampString = timestampString {            
            timestamp = Utils.dateFromTimestamp(timestamp: timestampString)
            timeAgoSinceNowString = Utils.timeAgoSinceNowString(fromDate: timestamp)

        } else {
            timestamp = Date()
        }
        
        let profileImageUrlString = dictionary["profile_image_url"] as? String
        if profileImageUrlString != nil {
            profileImageUrl = URL(string: profileImageUrlString!)
        } else {
            profileImageUrl = nil
        }
    
        let entitiesDictionary = dictionary["entities"] as? NSDictionary
        if let dict = entitiesDictionary {
            
            let userMentionsArray = dict["user_mentions"] as? [NSDictionary]
            let count = userMentionsArray?.count ?? 0
            log.verbose("user mentions count: \(count)")
            
            let mentions = UserMention.userMentionWithArray(dictionaries: userMentionsArray!)
            for m in mentions {
                log.verbose("id: \(String(describing: m.idStr)), name: \(String(describing: m.name))")
            }
            
            // Parse media entities
            let mediaArray = dict["media"] as? [NSDictionary]
            if let array = mediaArray {
                let medias = Media.mediasWithArray(dictionaries: array)
                mediaUrl = medias[0].url
            }
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

