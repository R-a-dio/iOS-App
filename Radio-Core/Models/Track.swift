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
    public var endTime: Double?
    
    public func song() -> String {
        var song = ""
        if let meta = metadata {
            let components = meta.componentsSeparatedByString(" - ")
            if components.count > 0 {
                song = components[0]
            }
        }
        
        return song
    }
    
    public func artist() -> String? {
        if let meta = metadata {
            let components = meta.componentsSeparatedByString(" - ")
            if components.count > 1 {
                return components[1]
            }
        }
        
        return nil
    }
    
    public func displayableMetadata() -> String {
        let songName = song()
        let artistName = artist()
        
        if let validArtist = artistName {
            return "\(songName)\n\(validArtist)"
        }
        
        return songName
    }
    
    public func displayableEndTime() -> String {
        let secondsToFinish = endTime == nil ? 0 : endTime!
        return stringFromSeconds(secondsToFinish)
    }
    
    public func displayableTime() -> String {
        if let date = start {
            let seconds = NSDate().timeIntervalSinceDate(date)
            return "\(stringFromSeconds(seconds)) / \(displayableEndTime())"
        }
        
        return displayableEndTime()
    }
    
    private func stringFromSeconds(seconds: Double) -> String {
        let rounded = Int(seconds)
        let totalSeconds = rounded % 60
        let totalMinutes = (rounded / 60) % 60
        
        return "\(String(format: "%02d", totalMinutes)):\(String(format: "%02d", totalSeconds))"
    }
    
}
