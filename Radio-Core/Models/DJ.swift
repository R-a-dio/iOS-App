//
//  DJ.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Foundation

public enum DJKey: String {
    case id
    case djname
    case visible
    case role
}

public class DJ {
    
    var id: Int
    
    var name: String
    var role: String?
    
    var imageData: NSData?
    
    var afk: Bool?
    var visible: Bool?
    
    var theme: Theme?
    
    init(object: [String : AnyObject]) {
        id = object[DJKey.id.rawValue] as! Int
        name = object[DJKey.djname.rawValue] as! String
        visible = object[DJKey.visible.rawValue] as? Bool
        role = object[DJKey.role.rawValue] as? String
    }

}
