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

extension DJ {
    
    func image(completion: (image: UIImage) -> Void) {
        func imageFromData() -> Bool {
            if let data = imageData, image = UIImage.gifWithData(data) {
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

class PlayerViewController: UIViewController, RadioPlayerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageDJ: UIImageView!
    @IBOutlet weak var labelDJ: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTrack: UILabel!
    @IBOutlet weak var buttonStream: UIButton!
    
    // MARK: - Properties
    
    var player = RadioPlayer()
    
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
        player.delegate = self
        
        imageDJ.layer.cornerRadius = 5.0
        imageDJ.layer.masksToBounds = true
        
        buttonStream.layer.cornerRadius = 3.0
        buttonStream.layer.masksToBounds = true
        
        resetUI()
    }
    
    func resetUI() {
        buttonStream.setTitle("Start Stream", forState: .Normal)
        labelTrack.text = ""
        labelDJ.text = ""
        labelTime.text = ""
        imageDJ.image = nil
    }
    
    // MARK: - Actions
    
    @IBAction func buttonStream(sender: UIButton) {
        let isPlaying = player.togglePlayer()
        sender.setTitle(isPlaying ? "Stop Stream" : "Play Stream", forState: .Normal)
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        player.volume = sender.value
    }
    
    // MARK: - RadioPlayer Delegate
    
    func radioStarted() {
    }
    
    func radioStopped() {
        resetUI()
    }
    
    func radioIsBuffering() {
        labelTrack.text = "Buffering"
    }
    
    func radioReceivedData(data: RadioData) {
        labelTrack.text = data.nowPlaying.displayableMetadata()
        labelDJ.text = data.dj.name
        
        data.dj.image { (image) in
            self.imageDJ.image = image
        }
    }
    
    func radioUpdatedTime(currentTime: Int) {
        labelTime.text = player.currentData?.nowPlaying.displayableTime()
    }

}
