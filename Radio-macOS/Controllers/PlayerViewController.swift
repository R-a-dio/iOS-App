//
//  PlayerViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Cocoa

extension DJ {
    
    func image(completion: (image: NSImage) -> Void) {
        func imageFromData() -> Bool {
            if let data = imageData, image = NSImage(data: data) {
                completion(image: image)
                return true
            }
            
            return false
        }
        
        if imageFromData() == true {
            return
        }
        
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
        imageDJ.layer?.cornerRadius = 8.0;
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
        imageDJ.imageScaling = .ScaleProportionallyUpOrDown
    }
    
    // MARK: - Actions
    
    @IBAction func buttonStream(sender: NSButton) {
        let isPlaying = player.togglePlayer()
        sender.title = isPlaying ? "Stop Stream" : "Play Stream"
    }
    
    @IBAction func sliderChanged(sender: NSSlider) {
        player.volume = sender.floatValue
    }
    
    // MARK: - RadioPlayer Delegate
    
    func radioStarted() {
        buttonToggle.title = "Stop Stream"
    }
    
    func radioStopped() {
        buttonToggle.title = "Start Stream"
        labelTrack.stringValue = ""
    }
    
    func radioIsBuffering() {
        labelTrack.stringValue = "Buffering"
        buttonToggle.title = "Stop Stream"
    }
    
    func radioReceivedData(data: RadioData) {
        labelTrack.stringValue = data.nowPlaying.displayableMetadata()
        
        data.dj.image { (image) in
            self.imageDJ.image = image
        }
    }
    
    func radioUpdatedTime(currentTime: Double) {
        
    }
    
    // MARK: - Application Delegate
    
    func appWillTerminate() {
        UserPreferences.saveVolume(player.volume)
    }
    
}
