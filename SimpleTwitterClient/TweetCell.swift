//
//  TweetCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            let user = tweet.user
            if user != nil {
                nameLabel.text = user?.name
                if let screenname = user?.screenname {
                    screenNameLabel.text = "@\(screenname)"
                } else {
                    screenNameLabel.text = "@"
                }
                
                timestampLabel.text = tweet.formattedTimestamp
                
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
                        print(error)
                    })
                } else {
                    // TODO: Use placeholder image
                }
                
            }
            
            tweetContentLabel.text = tweet.text
            
            
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // The profileImageView has dimension 48 x 48.  Set the corner radius to 24 (50%) to get round profile image
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
