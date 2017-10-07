//
//  TweetTableViewCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/6/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@objc protocol TweetTableViewCellDelegate {
    
    @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet)
    @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, retweet tweet: Tweet)
    @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, favorite tweet: Tweet)
    @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, showUserProfile user: User)
}

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var retweetedImageView: UIImageView!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetedCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    weak var delegate: TweetTableViewCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            
            log.verbose("tweet data: \(tweet.debugDescription)")
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
                
                if let profileImageUrl = user?.profileUrl {
                    Utils.fadeInImageAt(url: profileImageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), imageView: profileImageView)
                }
            }
            
            if let mediaUrl = tweet.mediaUrl {
                Utils.fadeInImageAt(url: mediaUrl, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), imageView: mediaImageView)
            }
            
            statusLabel.text = tweet.text
            
            retweetedCountLabel.text = "\(displayedTweet.retweetCount)"
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
        
        mediaImageView.clipsToBounds = true
        
        // Add a tap gesture recognizer to the profile image view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func profileImageTapped(_ sender: UITapGestureRecognizer) {        
        delegate?.tweetTableViewCell!(self, showUserProfile: tweet.user!)
    }
    
    @IBAction func replyButtonPressed(_ sender: Any) {
        
        delegate?.tweetTableViewCell!(self, replyTo: tweet)
    }
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
        
        delegate?.tweetTableViewCell!(self, retweet: tweet)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        
        delegate?.tweetTableViewCell!(self, favorite: tweet)
    }
}
