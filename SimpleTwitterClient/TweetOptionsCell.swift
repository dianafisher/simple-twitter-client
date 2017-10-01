//
//  TweetOptionsCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@objc protocol TweetOptionsCellDelegate {
    
    @objc optional func tweetOptionsCell(_ tweetOptionsCell: TweetOptionsCell, replyTo tweet: Tweet)
//    @objc optional func tweetOptionsCell(_ tweetOptionsCell: TweetOptionsCell, retweet tweet: Tweet)
//    @objc optional func tweetOptionsCell(_ tweetOptionsCell: TweetOptionsCell, favorite tweet: Tweet)
}

class TweetOptionsCell: UITableViewCell {
    
    weak var delegate: TweetOptionsCellDelegate?
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var tweet: Tweet! {
        didSet {
            // Set the favorited image
            if (tweet.hasFavorited) {
                favoriteButton.setImage(#imageLiteral(resourceName: "heart_red"), for: UIControlState.normal)
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "heart"), for: UIControlState.normal)
            }
            
            // Set the retweeted image
            if (tweet.hasRetweeted) {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet_aqua"), for: UIControlState.normal)
            } else {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: UIControlState.normal)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func replyButtonPressed(_ sender: Any) {
        delegate?.tweetOptionsCell!(self, replyTo: tweet)
    }
    
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
        
        if let tweetId = tweet.idString {
            // Determine if this is a retweet or an unretweet action.
            if tweet.hasRetweeted {
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unretweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    updatedTweet.hasRetweeted = false
                    
                    DispatchQueue.main.async {
                        self?.tweet = updatedTweet
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                TwitterClient.sharedInstance?.retweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    DispatchQueue.main.async {
                        self?.tweet = updatedTweet
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
            
        }
        
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a favorite or an unfavorite action.
            if tweet.hasFavorited {
                                
                TwitterClient.sharedInstance?.unlikeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    DispatchQueue.main.async {
                        self?.tweet = updatedTweet
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    DispatchQueue.main.async {
                        self?.tweet = updatedTweet
                    }
                    
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
