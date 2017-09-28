//
//  Entity.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/28/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class Entity: NSObject {
    
    var indices: [Int]?
    
    init(dictionary: NSDictionary) {
        
        indices = dictionary["indices"] as? [Int]
    }
}
