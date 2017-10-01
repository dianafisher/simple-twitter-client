//
//  TweetCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    
    @objc optional func tweetCell(_ tweetCell: TweetCell, replyTo tweet: Tweet)
    @objc optional func tweetCell(_ tweetCell: TweetCell, retweet tweet: Tweet)
    @objc optional func tweetCell(_ tweetCell: TweetCell, favorite tweet: Tweet)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var retweetedImageView: UIImageView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            
            log.verbose("setting tweet data: \(tweet.debugDescription)")
            var displayedTweet: Tweet = tweet
            
            // Is this a retweet?
            if tweet.retweet != nil {
                retweetedLabel.isHidden = false
                retweetedImageView.isHidden = false
                
                displayedTweet = tweet.retweet!
                let retweeter = tweet.user?.name ?? ""
                retweetedLabel.text = "\(retweeter) retweeted"
            } else {
                retweetedLabel.isHidden = true
                retweetedImageView.isHidden = true
            }
            
            let user = displayedTweet.user
            if user != nil {
                nameLabel.text = user?.name
                if let screenname = user?.screenname {
                    screenNameLabel.text = "@\(screenname)"
                } else {
                    screenNameLabel.text = "@"
                }
                
                timestampLabel.text = displayedTweet.timeAgoSinceNowString
                
                if let profileImageUrl = user?.profileUrl
                {
                    let imageRequest = URLRequest(url: profileImageUrl)
                    profileImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                        self.profileImageView.alpha = 0.0
                        self.profileImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: {
                            self.profileImageView.alpha = 1.0
                        })
                    }, failure: { (imageRequest, imageResponse, error) in
                        log.error(error)
                    })
                } else {
                    // Use a placeholder image instead.
                    profileImageView.image = #imageLiteral(resourceName: "placeholder_profile")
                }
                
            }
            
//            log.verbose("disp layedTweet: \(displayedTweet)")
            
            tweetContentLabel.text = displayedTweet.text
            
            retweetCountLabel.text = "\(displayedTweet.retweetCount)"
            favoriteCountLabel.text = "\(displayedTweet.favoriteCount)"
            
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
        
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func replyButtonPressed(_ sender: Any) {
        
        delegate?.tweetCell!(self, replyTo: tweet)
    }
    
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
        
        delegate?.tweetCell!(self, retweet: tweet)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        
        delegate?.tweetCell!(self, favorite: tweet)
    }
    
}
