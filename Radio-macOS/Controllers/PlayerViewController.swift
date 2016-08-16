//
//  PlayerViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Cocoa

extension NSImage {
    
    static func imagePossibleAnimatable(data: NSData) -> (image: NSImage?, animates: Bool) {
        if data.length == 0 {
            return (image: nil, animates: false)
        }
        
        var imageExtensionData = 0
        data.getBytes(&imageExtensionData, length: 1)
        
        if let imageExtension = ImageExtensionData(rawValue: imageExtensionData) {
            switch imageExtension {
            case .GIF:
                return (image: NSImage(data: data), animates: true)
                
            default:
                break
            }
        }
        
        return (image: NSImage(data: data), animates: false)
    }
    
}

extension DJ {
    
    func image(completion: (image: NSImage, animates: Bool) -> Void) {
        func imageFromData() -> Bool {
            if let data = imageData {
                let imageInfo = NSImage.imagePossibleAnimatable(data)
                
                if let image = imageInfo.image {
                    completion(image: image, animates: imageInfo.animates)
                    return true
                }
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

class PlayerViewController: NSViewController, RadioPlayerDelegate, ApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageDJ: NSImageView!
    @IBOutlet weak var labelTrack: NSTextField!
    @IBOutlet weak var labelTime: NSTextField!
    @IBOutlet weak var buttonToggle: NSButton!
    @IBOutlet weak var sliderVolume: NSSlider!
    
    // MARK: - Properties
    
    var player = RadioPlayer.sharedPlayer
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        imageDJ.layer?.cornerRadius = 5.0;
        imageDJ.layer?.masksToBounds = true;
    }
    
    // MARK: - Setup
    
    func setupView() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.delegate = self
        
        let volume = UserPreferences.volume()
        
        player.delegate = self
        player.volume = volume
        
        sliderVolume.floatValue = volume
        imageDJ.wantsLayer = true
        imageDJ.imageScaling = .ScaleNone
        //imageDJ.canDrawSubviewsIntoLayer = true // COMMENTED BECAUSE OF HUGE CPU USAGE, BUT GIFS DONT WORK WITHOUT THIS :(
    }
    
    // MARK: - Actions
    
    @IBAction func buttonStream(sender: NSButton) {
        let isPlaying = player.togglePlayer()
        sender.title = isPlaying ? Localized.string("Stop Stream") : Localized.string("Start Stream")
    }
    
    @IBAction func sliderChanged(sender: NSSlider) {
        player.volume = sender.floatValue
    }
    
    // MARK: - RadioPlayer Delegate
    
    func radioStarted() {
        buttonToggle.title = Localized.string("Stop Stream")
    }
    
    func radioStopped() {
        buttonToggle.title = Localized.string("Start Stream")
        labelTrack.stringValue = ""
        labelTime.stringValue = ""
    }
    
    func radioIsBuffering() {
        labelTrack.stringValue = Localized.string("Buffering")
        labelTime.stringValue = ""
        buttonToggle.title = Localized.string("Stop Stream")
    }
    
    func radioReceivedData(data: RadioData) {
        labelTrack.stringValue = data.nowPlaying.displayableMetadata()
        
        data.dj.image { (image, animates) in
            let height = self.imageDJ.frame.size.height
            let aspect = image.size.width / image.size.height
            image.size = CGSizeMake(height * (aspect), height)
            
            self.imageDJ.image = image
            self.imageDJ.animates = animates
        }
    }
    
    func radioUpdatedTime(currentTime: Double) {
        if let time = player.currentData?.nowPlaying.displayableTime() {
            labelTime.stringValue = time
        }
    }
    
    // MARK: - Application Delegate
    
    func appWillTerminate() {
        UserPreferences.saveVolume(player.volume)
    }
    
}
