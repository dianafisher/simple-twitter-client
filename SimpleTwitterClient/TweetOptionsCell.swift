//
//  TweetOptionsCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class TweetOptionsCell: UITableViewCell {

    var tweet: Tweet!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func replyButtonPressed(_ sender: Any) {
//        if let tweet = tweet {
//            if let tweetId = tweet.idString {
//                let username = tweet.user?.name ?? ""
//                
//                TwitterClient.sharedInstance?.replyToTweet(tweetId: tweetId, username: username, status: <#T##String#>, success: <#T##(Bool) -> ()#>, failure: <#T##(Error) -> ()#>)
//            }
//        }
    }
    
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
        if let tweet = tweet {
            if let tweetId = tweet.idString {
                TwitterClient.sharedInstance?.retweet(tweetId: tweetId, success: { (success) in
                    if (success) {
                        print("YAY! I retweeted")
                    }
                }, failure: { (error: Error) in
                    print("Error: \(error.localizedDescription)")
                })
            }            
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if let tweet = tweet {
            if let tweetId = tweet.idString {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { (success) in
                    if (success) {
                        print("YAY! I liked someting")
                    }
                }, failure: { (error: Error) in
                    print("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
    }
}
