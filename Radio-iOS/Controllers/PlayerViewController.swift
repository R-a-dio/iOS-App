//
//  PlayerViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import UIKit
import MediaPlayer
import AVFoundation
import SwiftGifOrigin

extension UIImage {
    
    static func imagePossibleAnimatable(data: NSData) -> UIImage? {
        if data.length == 0 {
            return nil
        }
        
        var imageExtensionData = 0
        data.getBytes(&imageExtensionData, length: 1)
        
        if let imageExtension = ImageExtensionData(rawValue: imageExtensionData) {
            switch imageExtension {
            case .GIF:
                return UIImage.gifWithData(data)
                
            default:
                break
            }
        }
        
        return UIImage(data: data)
    }
    
}

extension DJ {
    
    func image(completion: (image: UIImage) -> Void) {
        func imageFromData() -> Bool {
            if let data = imageData, image = UIImage.imagePossibleAnimatable(data) {
                completion(image: image)
                return true
            }
            
            return false
        }
        
        if imageFromData() == true {
            return
        }
        
        imageData = NSMutableData(capacity: 0)
        ImageAPI.getDJImage(self, completion: { (image) in
            self.imageData = image
            _ = imageFromData()
        })
    }
    
}

class PlayerViewController: UIViewController, RadioPlayerDelegate, ConnectivityDataSource, ApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageDJ: UIImageView!
    @IBOutlet weak var labelTimeCurrent: UILabel!
    @IBOutlet weak var labelTimeEnd: UILabel!
    @IBOutlet weak var labelTimeCurrentProgress: UILabel!
    @IBOutlet weak var labelTimeEndProgress: UILabel!
    @IBOutlet weak var labelTrack: UILabel!
    @IBOutlet weak var buttonStream: UIButton!
    @IBOutlet weak var viewDJOverlay: UIView!
    @IBOutlet weak var labelDJRole: UILabel!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var constraintProgress: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var listController: UIViewController?
    var player = RadioPlayer.sharedPlayer
    let connectivity = Connectivity()
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup
    
    func setupView() {
        // BE AWARE OF APP CLOSE
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.delegate = self
        
        // WATCH CONNECTIVITY
        connectivity.dataSource = self
        connectivity.startSession()
        
        // PLAYER
        player.delegate = self
        
        // PLAYER UI
        imageDJ.layer.cornerRadius = 5.0
        imageDJ.layer.masksToBounds = true
        
        viewDJOverlay.layer.cornerRadius = 5.0
        viewDJOverlay.layer.masksToBounds = true
        
        buttonStream.layer.cornerRadius = 3.0
        buttonStream.layer.masksToBounds = true
        
        viewDJOverlay.alpha = 0
        
        // MAKE LIST TAB GO AWAY
        hideListTab(true)
        
        // TOUCH
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.tapDJ))
        tap.numberOfTapsRequired = 1
        imageDJ.addGestureRecognizer(tap)
        
        // PUT UI ON STOP STATE
        resetUI()
    }

    func resetUI() {
        buttonStream.setTitle(Localized.string("Start Stream"), forState: .Normal)
        labelTrack.text = ""
        labelTimeCurrent.text = ""
        labelTimeEnd.text = ""
        labelTimeCurrentProgress.text = ""
        labelTimeEndProgress.text = ""
        imageDJ.image = nil
        viewDJOverlay.alpha = 0
        constraintProgress.constant = view.frame.width
    }
    
    // MARK: - Tabs
    
    func hideListTab(hide: Bool) {
        tabBarController?.tabBar.hidden = hide
    }
    
    // MARK: - Connectivity
    
    func sendTrackContext(track: Track) {
        let trackContext = RadioContext()
        trackContext.isPlaying = player.isPlaying
        trackContext.nowPlaying = track
        connectivity.sendContext(trackContext)
    }
    
    func sendDJContext(dj: DJ) {
        let djContext = RadioContext()
        djContext.isPlaying = self.player.isPlaying
        djContext.dj = dj
        connectivity.sendContext(djContext)
    }
    
    func sendStopContext() {
        let context = RadioContext()
        context.isPlaying = false
        self.connectivity.sendContext(context)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonStream(sender: UIButton) {
        MediaManager.startSession(player)
        
        let isPlaying = player.togglePlayer()
        sender.setTitle(isPlaying ? Localized.string("Stop Stream") : Localized.string("Start Stream"), forState: .Normal)
    }
    
    func tapDJ(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            if player.isPlaying == false {
                return
            }
            
            UIView.animateWithDuration(0.2) {
                self.viewDJOverlay.alpha = self.viewDJOverlay.alpha.isZero ? 1 : 0
            }
            
        default:
            break
        }
    }
    
    // MARK: - RadioPlayer Delegate
    
    func radioStarted() {
        buttonStream.setTitle(Localized.string("Stop Stream"), forState: .Normal)
        
        if let data = player.currentData {
            radioReceivedData(data)
        }
    }
    
    func radioStopped() {
        hideListTab(true)
        sendStopContext()
        
        MediaManager.cleanCenter()
        
        resetUI()
    }
    
    func radioIsBuffering() {
        labelTrack.text = Localized.string("Buffering")
        buttonStream.setTitle(Localized.string("Stop Stream"), forState: .Normal)
    }
    
    func radioReceivedData(data: RadioData) {
        if player.isPlaying == false {
            return
        }
        
        hideListTab(false)
        labelDJRole.text = data.dj.name
        if let listeners = data.listeners {
            labelDJRole.text = "\(labelDJRole.text!)\n\(listeners) \(Localized.string(listeners == 1 ? "Listener" : "Listeners"))"
        }
        
        data.dj.image { (image) in
            self.imageDJ.image = image
            self.sendDJContext(data.dj)
        }
        
        let currentTime = data.nowPlaying.displayableCurrentTime()
        labelTimeCurrent.text = currentTime
        labelTimeCurrentProgress.text = currentTime
        
        let endTime = "/ \(data.nowPlaying.displayableEndTime())"
        labelTimeEnd.text = endTime
        labelTimeEndProgress.text = endTime
        
        if player.playerState != .FsAudioStreamPlaying {
            // PLAYER MIGHT STILL BE BUFFERING, SO NOT UPDATING THE LABEL YET
            return
        }
        
        labelTrack.text = data.nowPlaying.displayableMetadata()
        
        MediaManager.updateCenter(data)
        self.sendTrackContext(data.nowPlaying)
    }
    
    func radioUpdatedTime(currentTime: Double) {
        let timeText = player.currentData?.nowPlaying.displayableCurrentTime()
        labelTimeCurrent.text = timeText
        labelTimeCurrentProgress.text = timeText
        
        if let current = player.currentData?.nowPlaying.currentTime, end = player.currentData?.nowPlaying.endTime {
            constraintProgress.constant = end == 0 ? view.frame.width : view.frame.width * CGFloat(1.0 - (current / end))
        }
    }
    
    // MARK: - Connectivity DataSource
    
    func connectivityCalledMethod(method: ConnectivityMethod) {
        switch method {
        case .Play:
            player.startPlaying()
            
        case .Stop:
            player.stopPlaying()
        }
    }
    
    // MARK: - Application Delegate
    
    func appWillTerminate() {
        sendStopContext()
    }

}
