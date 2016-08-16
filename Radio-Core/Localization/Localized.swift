//
//  Localized.swift
//  Radio
//
//  Created by Rodrigo Prestes on 8/16/16.
//
//

import Foundation

public struct Localized {

    public static func string(toLocalize: String) -> String {
        return NSLocalizedString(toLocalize, comment: "")
    }
    
}
