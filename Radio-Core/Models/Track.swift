//
//  Track.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Foundation

public class Track {
    
    public var metadata: String?
    
    public var start: NSDate?
    public var end: NSDate?
    
    public var currentTime: Double?
    
    public func displayString() -> String {
        var song = ""
        if let meta = metadata {
            var artist: String?
            
            let components = meta.componentsSeparatedByString(" - ")
            if components.count > 0 {
                song = components[0]
            }
            
            if components.count > 1 {
                artist = components[1]
            }
            
            if let validArtist = artist {
                return "\(song)\n\(validArtist)"
            }
        }
        
        return song
    }
    
}
