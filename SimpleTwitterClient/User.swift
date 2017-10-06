//
//  User.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var idStr: String?
    var name: String?
    var screenname: String?
    var profileUrl: URL?
    var profileBackgroundUrl: URL?
    var tagline: String?
    var location: String?
    var url: URL?
    var verified: Bool
    var followersCount: Int = 0
    var friendsCount: Int = 0
    var listedCount: Int = 0
    var favoritesCount: Int = 0
    var statusesCount: Int = 0
    
    
    var dictionary: NSDictionary?
    
    // hidden class variable
    static var _currentUser: User?
    static let userDidLogoutNotification = "UserDidLogout"
 
    
    override var description: String {
        
        let str = "User --> name: \(name ?? "none")), screename: \(screenname ?? "none"), profileUrl: \(String(describing: profileUrl)))<--"
        return str
    }
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
//        log.verbose(dictionary)
        
        // deserialization 
        idStr = dictionary["id_str"] as? String
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        
        let profileBackgroundUrlString = dictionary["profile_banner_url"] as? String
        if let profileBackgroundUrlString = profileBackgroundUrlString {
            profileBackgroundUrl = URL(string: profileBackgroundUrlString)
        }
        
        tagline = dictionary["description"] as? String
        location = dictionary["location"] as? String
        
        let urlString = dictionary["url"] as? String
        if let urlString = urlString {
            url = URL(string: urlString)
        }
        
        verified = (dictionary["verified"] as? Bool) ?? false
        
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        friendsCount = (dictionary["friends_count"] as? Int) ?? 0
        listedCount = (dictionary["listed_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        statusesCount = (dictionary["statuses_count"] as? Int) ?? 0
    }
    
   
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                
                if let userData = userData {
                    let dictionary = try!
                        JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    
                    _currentUser = User(dictionary: dictionary)
                }
                
                
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try!
                    JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                    defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.set(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
        }
    }    
}
