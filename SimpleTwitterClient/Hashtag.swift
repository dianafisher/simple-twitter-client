//
//  Hashtag.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/28/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class Hashtag: Entity {
    
    var text: String?
    
    override init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        
        text = dictionary["text"] as? String
    }
}
