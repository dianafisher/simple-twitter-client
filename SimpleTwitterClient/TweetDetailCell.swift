//
//  TweetDetailCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class TweetDetailCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            let user = tweet.user
            if user != nil {
                nameLabel.text = user?.name
                if let screenname = user?.screenname {
                    screennameLabel.text = "@\(screenname)"
                } else {
                    screennameLabel.text = "@"
                }
                
                timeStampLabel.text = tweet.formattedTimestamp
                
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
            
            tweetTextLabel.text = tweet.text
            
            
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
