//
//  TweetDetailCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@objc protocol TweetDetailCellDelegate {
    @objc optional func tweetDetailCell(_ tweetDetailCell: TweetDetailCell, showUserProfile user: User)
}

class TweetDetailCell: UITableViewCell {
    
    weak var delegate: TweetDetailCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var retweetedImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    var tweet: Tweet! {
        didSet {
            
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
                    screennameLabel.text = "@\(screenname)"
                } else {
                    screennameLabel.text = "@"
                }
                
                timeStampLabel.text = displayedTweet.formattedDateString
                
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
                    // TODO: Use placeholder image
                }
                
            }
            
            tweetTextLabel.text = tweet.text
            
            if let mediaUrl = tweet.mediaUrl {
                let imageRequest = URLRequest(url: mediaUrl)
                mediaImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (request, response, image) in
                    
                    self.mediaImageView.alpha = 0.0
                    self.mediaImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.mediaImageView.alpha = 1.0                        
                        self.mediaImageView.setNeedsDisplay()
                    })
                    
                }, failure: { (request, response, error) in
                    log.error(error)
                })
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        tweetTextLabel.preferredMaxLayoutWidth = tweetTextLabel.frame.size.width
        
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
        
        var user = tweet.user!
        
        // Is this a retweet?
        if (tweet.retweet != nil) {
            user = (tweet.retweet?.user)!
        }
        
        delegate?.tweetDetailCell!(self, showUserProfile: user)
    }

}
