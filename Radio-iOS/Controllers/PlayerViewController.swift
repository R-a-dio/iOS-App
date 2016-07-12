//
//  PlayerViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import UIKit
import AVFoundation
import SwiftGifOrigin

extension UIImage {
    
    private enum ImageExtensionData: Int {
        case JPEG = 0xFF
        case PNG = 0x89
        case GIF = 0x47
        case TIFF_II = 0x49
        case TIFF_MM = 0x4D
        case NONE = 0
    }
    
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

class PlayerViewController: UIViewController, RadioPlayerDelegate, ConnectivityDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageDJ: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTrack: UILabel!
    @IBOutlet weak var buttonStream: UIButton!
    @IBOutlet weak var viewDJOverlay: UIView!
    @IBOutlet weak var labelDJRole: UILabel!
    
    // MARK: - Properties
    
    var player = RadioPlayer()
    let connectivity = Connectivity()
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectivity.dataSource = self
        connectivity.startSession()
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup
    
    func setupView() {
        player.delegate = self
        
        imageDJ.layer.cornerRadius = 5.0
        imageDJ.layer.masksToBounds = true
        
        viewDJOverlay.layer.cornerRadius = 5.0
        viewDJOverlay.layer.masksToBounds = true
        
        buttonStream.layer.cornerRadius = 3.0
        buttonStream.layer.masksToBounds = true
        
        viewDJOverlay.alpha = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.tapDJ))
        tap.numberOfTapsRequired = 1
        imageDJ.addGestureRecognizer(tap)
        
        resetUI()
    }

    func resetUI() {
        buttonStream.setTitle("Start Stream", forState: .Normal)
        labelTrack.text = ""
        labelTime.text = ""
        imageDJ.image = nil
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
        sender.setTitle(isPlaying ? "Stop Stream" : "Play Stream", forState: .Normal)
    }
    
    func tapDJ(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            UIView.animateWithDuration(0.2) {
                self.viewDJOverlay.alpha = self.viewDJOverlay.alpha.isZero ? 1 : 0
            }
            
        default:
            break
        }
    }
    
    // MARK: - RadioPlayer Delegate
    
    func radioStarted() {
        buttonStream.setTitle("Stop Stream", forState: .Normal)
        
        if let data = player.currentData {
            radioReceivedData(data)
        }
    }
    
    func radioStopped() {
        MediaManager.cleanCenter()
        
        sendStopContext()
        
        resetUI()
    }
    
    func radioIsBuffering() {
        labelTrack.text = "Buffering"
        buttonStream.setTitle("Stop Stream", forState: .Normal)
    }
    
    func radioReceivedData(data: RadioData) {
        if let role = data.dj.role {
            labelDJRole.text = "\(data.dj.name)\n\n\(role)"
        }
        else {
            labelDJRole.text = data.dj.name
        }
        
        data.dj.image { (image) in
            self.imageDJ.image = image
            self.sendDJContext(data.dj)
        }
        
        if player.playerState != .FsAudioStreamPlaying {
            return
        }
        
        labelTrack.text = data.nowPlaying.displayableMetadata()
        
        MediaManager.updateCenter(data)
        self.sendTrackContext(data.nowPlaying)
    }
    
    func radioUpdatedTime(currentTime: Double) {
        labelTime.text = player.currentData?.nowPlaying.displayableTime()
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

}
