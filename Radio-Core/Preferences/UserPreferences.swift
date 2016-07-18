//
//  UserPreferences.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/18/16.
//
//

import Foundation

public struct UserPreferences {

    // MARK: - Properties
    
    private static let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - Defaults
    
    public static func registerDefaults() {
        defaults.registerDefaults([volumeKey : Float(1.0)])
    }
    
    // MARK: - Volume
    
    private static let volumeKey = "Volume"
    
    public static func volume() -> Float {
        return defaults.floatForKey(volumeKey)
    }
    
    public static func saveVolume(volume: Float) {
        if volume == self.volume() {
            return
        }
        
        defaults.setFloat(volume, forKey: volumeKey)
    }
    
}
