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

class PlayerViewController: NSViewController, RadioPlayerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageDJ: NSImageView!
    @IBOutlet weak var labelTrack: NSTextField!
    @IBOutlet weak var buttonToggle: NSButton!
    
    // MARK: - Properties
    
    var player = RadioPlayer()
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    
    func setupView() {
        player.delegate = self
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
    }
    
    func radioStopped() {
        buttonToggle.title = "Start Stream"
        labelTrack.stringValue = ""
    }
    
    func radioIsBuffering() {
        labelTrack.stringValue = "Buffering"
    }
    
    func radioReceivedData(data: RadioData) {
        labelTrack.stringValue = data.nowPlaying.displayableMetadata()
        
        data.dj.image { (image) in
            self.imageDJ.image = image
        }
    }
    
    func radioUpdatedTime(currentTime: Double) {
        
    }
    
}
