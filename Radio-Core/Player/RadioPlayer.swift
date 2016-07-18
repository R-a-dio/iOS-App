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
    func radioUpdatedTime(currentTime: Double)
}

public protocol RadioPlayerDataDelegate {
    func radioUpdatedData(data: RadioData?)
}

public class RadioPlayer {

    // MARK: - Singleton
    
    public static let sharedPlayer = RadioPlayer()
    
    // MARK: - Properties
    
    private var timer: NSTimer?
    private lazy var player: FSAudioStream = {
        let preloadSize: Int32 = 250 // SIZE IN KB
        
        let configuration = FSStreamConfiguration()
        configuration.userAgent = NSBundle.mainBundle().bundleIdentifier
        configuration.cacheEnabled = false
        configuration.usePrebufferSizeCalculationInSeconds = false
        configuration.requiredInitialPrebufferedByteCountForContinuousStream = preloadSize * 1024
        
        let radioPlayer = FSAudioStream(configuration: configuration)
        radioPlayer.volume = self.volume
        
        radioPlayer.onStateChange = { state in
            self.playerState = state
            
            switch state {
            case .FsAudioStreamBuffering,
                 .FsAudioStreamRetryingStarted:
                self.delegate?.radioIsBuffering()
                
            case .FsAudioStreamPlaying:
                self.delegate?.radioStarted()
                if let data = self.currentData {
                    self.delegate?.radioReceivedData(data)
                }
                
            case .FsAudioStreamFailed,
                 .FsAudioStreamStopped,
                 .FsAudioStreamRetryingFailed:
                self.stopPlaying()
                self.delegate?.radioStopped()
            
            default:
                break
            }
        }
        
        radioPlayer.onFailure = { fail, error in
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
    
    public var delegate: RadioPlayerDelegate?
    public var dataDelegate: RadioPlayerDataDelegate?
    
    public var currentData: RadioData? {
        didSet {
            dataDelegate?.radioUpdatedData(currentData)
        }
    }
    
    public var volume: Float = 1.0 {
        didSet {
            player.volume = volume
        }
    }
    
    public var playerState: FSAudioStreamState = .FsAudioStreamUnknownState
    public var isPlaying: Bool = false
    
    // MARK: - Player
    
    public func startPlaying() {
        isPlaying = true
        let streamURL = NSURL(string: "https://stream.r-a-d.io/main.mp3")!
        self.player.playFromURL(streamURL)
        
        requestAPI()
    }
    
    public func stopPlaying() {
        isPlaying = false
        stopTimer()
        player.stop()
    }
    
    public func togglePlayer() -> Bool {
        if isPlaying {
            stopPlaying()
        }
        else {
            startPlaying()
        }
        
        return isPlaying
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
