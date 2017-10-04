//
//  MenuItemCell.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/3/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForMenuItem(_ menuItem: NSDictionary) {
        
        textLabel?.text = menuItem["text"] as? String
        backgroundColor = menuItem["color"] as? UIColor
    }

}
