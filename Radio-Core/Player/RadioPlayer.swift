//
//  RadioPlayer.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import AVFoundation
import FreeStreamer

public protocol RadioPlayerDelegate {
    
    func radioIsBuffering()
    func radioStarted()
    func radioStopped()
    func radioReceivedData(data: RadioData)
    func radioUpdatedTime(currentTime: Int)
    
}

public class RadioPlayer {

    // MARK: - Properties
    
    private var timer: NSTimer?
    private lazy var player: FSAudioStream = {
        let preloadSize: Int32 = 150 // NUMBER IN KB
        
        let configuration = FSStreamConfiguration()
        configuration.userAgent = NSBundle.mainBundle().bundleIdentifier
        configuration.cacheEnabled = false
        configuration.usePrebufferSizeCalculationInSeconds = false
        configuration.requiredInitialPrebufferedByteCountForContinuousStream = preloadSize * 1024
        
        let radioPlayer = FSAudioStream(configuration: configuration)
        radioPlayer.volume = self.volume
        
        radioPlayer.onStateChange = { state in
            switch state {
                
            case .FsAudioStreamBuffering:
                self.delegate?.radioIsBuffering()
                
            case .FsAudioStreamPlaying:
                self.delegate?.radioStarted()
                
            case .FsAudioStreamFailed,
                 .FsAudioStreamStopped:
                self.delegate?.radioStopped()
                
            default:
                break
            }
        }
        
        radioPlayer.onFailure = { fail, error in
            self.delegate?.radioStopped()
            
            switch fail {
            case .FsAudioStreamErrorStreamParse:
                NSLog("ERROR PARSING")
                
            case .FsAudioStreamErrorNone:
                NSLog("ERROR NONE")
                
            case .FsAudioStreamErrorOpen:
                NSLog("ERROR OPEN")
                
            case .FsAudioStreamErrorNetwork:
                NSLog("ERROR NETWORK")
                
            case .FsAudioStreamErrorUnsupportedFormat:
                NSLog("ERROR FORMAT")
                
            case .FsAudioStreamErrorStreamBouncing:
                NSLog("ERROR BOUNCE")
                
            case .FsAudioStreamErrorTerminated:
                NSLog("ERROR TERMINATED")
            }
        }
        
        radioPlayer.onMetaDataAvailable = { metadata in
            if let trackInfo = metadata["StreamTitle"] as? String {
                if trackInfo != self.currentData?.nowPlaying.metadata {
                    self.requestAPI()
                }
            }
        }
        
        return radioPlayer
    }()
    
    //private var fallbackPlayer: AVAudioPlayer?
    
    public var currentData: RadioData?
    public var delegate: RadioPlayerDelegate?
    public var volume: Float = 1.0 {
        didSet {
            player.volume = volume
        }
    }
    
    public var isPlaying: Bool? {
        get {
            return player.isPlaying()
        }
    }
    
    // MARK: - Player
    
    public func startPlaying() {
        let streamURL = NSURL(string: "https://stream.r-a-d.io/main.mp3")!
        self.player.playFromURL(streamURL)
        
        requestAPI()
    }
    
    public func stopPlayer() {
        stopTimer()
        player.stop()
    }
    
    public func togglePlayer() -> Bool {
        let playing = player.isPlaying() == true
        
        if playing {
            stopPlayer()
        }
        else {
            startPlaying()
        }
        
        return !playing
    }
    
    // MARK: Timer
    
    private func startTimer() {
        if timer != nil {
            return
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RadioPlayer.updateTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateTimer() {
        if let time = currentData?.nowPlaying.currentTime {
            currentData!.nowPlaying.currentTime = time + 1
            delegate?.radioUpdatedTime(time)
        }
    }
    
    // MARK: - API
    
    private func requestAPI() {
        RadioAPI.getData { (data) in
            if let receivedData = data {
                var oldDJ: DJ?
                
                if let oldData = self.currentData {
                    oldDJ = oldData.dj
                }
                
                self.currentData = receivedData
                
                if oldDJ?.id == receivedData.dj.id {
                    let dj = self.currentData!.dj
                    dj.imageData = oldDJ?.imageData
                }
                
                self.delegate?.radioReceivedData(receivedData)
                self.startTimer()
                
                return
            }
            
            self.stopTimer()
        }
    }
    
}
