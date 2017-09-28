//
//  UserMention.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/28/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class UserMention: Entity {

    var idStr: String?    
    var name: String?
    var screenName: String?
    
    override init(dictionary: NSDictionary) {
    
        super.init(dictionary: dictionary)
        
        idStr = dictionary["id_str"] as? String
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
                
    }
    
    class func userMentionWithArray(dictionaries: [NSDictionary]) -> [UserMention] {
        var userMentions = [UserMention]()
        
        for dictionary in dictionaries {
            let userMention = UserMention(dictionary: dictionary)
            userMentions.append(userMention)
        }
        
        return userMentions
    }
}
