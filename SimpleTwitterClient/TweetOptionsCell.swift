//
//  TweetOptionsCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@objc protocol TweetOptionsCellDelegate {
    
    @objc optional func tweetOptionsCell(_ tweetOptionsCell: TweetOptionsCell, doReplyTo tweet: Tweet)
}

class TweetOptionsCell: UITableViewCell {

    var tweet: Tweet!
    
    weak var delegate: TweetOptionsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func replyButtonPressed(_ sender: Any) {
        delegate?.tweetOptionsCell!(self, doReplyTo: tweet)
    }
    
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
        if let tweetId = tweet.idString {
            TwitterClient.sharedInstance?.retweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                
                
                }, failure: { (error: Error) in
                    log.error("Error: \(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if let tweet = tweet {
            if let tweetId = tweet.idString {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                                        
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        // Do nothing..
    }
}
