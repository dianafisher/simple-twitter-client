//
//  Media.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/30/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class Media: Entity {

    var idStr: String?
    var url: URL?
    var type: String?
    
    override init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        
        idStr = dictionary["id_str"] as? String
        
        let urlString = dictionary["media_url"] as? String
        if let urlString = urlString {
            url = URL(string: urlString)
        }
        
        type = dictionary["type"] as? String
        
    }
    
    class func mediasWithArray(dictionaries: [NSDictionary]) -> [Media] {
        var medias = [Media]()
        
        for dictionary in dictionaries {
            let media = Media(dictionary: dictionary)
            medias.append(media)
        }
        
        return medias
    }
}
