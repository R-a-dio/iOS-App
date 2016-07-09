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
    
    public var currentTime: Int?
    public var endTime: Int?
    
    public func displayableMetadata() -> String {
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
    
    public func displayableTime() -> String {
        func stringFromSeconds(seconds: Int) -> String {
            let totalSeconds = seconds % 60
            let totalMinutes = (seconds / 60) % 60
            
            return "\(String(format: "%02d", totalMinutes)):\(String(format: "%02d", totalSeconds))"
        }
        
        let secondsToFinish = endTime == nil ? 0 : endTime!
        if let time = currentTime {
            return "\(stringFromSeconds(time)) / \(stringFromSeconds(secondsToFinish))"
        }
        
        return stringFromSeconds(secondsToFinish)
    }
    
}
