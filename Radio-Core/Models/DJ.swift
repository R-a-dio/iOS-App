//
//  DJ.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Foundation

public class DJ {
    
    var id: Int
    
    var name: String
    var role: String?
    
    var imageData: NSData?
    
    var afk: Bool?
    var visible: Bool?
    
    var theme: Theme?
    
    init(object: [String : AnyObject]) {
        id = object["id"] as! Int
        name = object["djname"] as! String
        visible = object["visible"] as? Bool
        role = object["role"] as? String
    }

}
