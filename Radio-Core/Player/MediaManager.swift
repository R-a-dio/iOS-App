//
//  MediaManager.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/11/16.
//
//

import UIKit
import MediaPlayer
import AVFoundation

public struct MediaManager {

    // MARK: - Session
    
    static func startSession(player: RadioPlayer) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
            
            let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
            
            commandCenter.playCommand.addTargetWithHandler({ (event) -> MPRemoteCommandHandlerStatus in
                player.startPlaying()
                return .Success
            })
            
            commandCenter.pauseCommand.addTargetWithHandler({ (event) -> MPRemoteCommandHandlerStatus in
                player.stopPlaying()
                return .Success
            })
            
            commandCenter.previousTrackCommand.enabled = false
            commandCenter.nextTrackCommand.enabled = false
        }
        catch {
            NSLog("Could not open audio session")
        }
    }
    
    // MARK: - Info Center
    
    static func updateCenter(data: RadioData) {
        let mediaCenter = MPNowPlayingInfoCenter.defaultCenter()
        
        var info: [String : AnyObject] = [
            MPMediaItemPropertyTitle : data.nowPlaying.song(),
            MPMediaItemPropertyAlbumTitle : "R/a/dio",
            MPNowPlayingInfoPropertyPlaybackRate: 1,
            MPNowPlayingInfoPropertyPlaybackQueueCount : 1,
            MPMediaItemPropertyMediaType : MPMediaType.AnyAudio.rawValue
        ]
        
        if let start = data.nowPlaying.start, end = data.nowPlaying.end {
            info[MPMediaItemPropertyPlaybackDuration] = end.timeIntervalSinceDate(start)
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSDate().timeIntervalSinceDate(start)
        }
        
        if let artist = data.nowPlaying.artist() {
            info[MPMediaItemPropertyArtist] = artist
        }
        
        if let imageData = data.dj.imageData, image = UIImage(data: imageData) {
            let artwork = MPMediaItemArtwork(image: image)
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        mediaCenter.nowPlayingInfo = info
    }
    
    static func cleanCenter() {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
    }
    
}
