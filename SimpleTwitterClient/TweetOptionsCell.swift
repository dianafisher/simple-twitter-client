//
//  TweetOptionsCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class TweetOptionsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func replyButtonPressed(_ sender: Any) {
        print("reply!")
    }
    
    
    @IBAction func retweetButtonPressed(_ sender: Any) {
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
    }
}
