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
    @IBOutlet weak var viewDJOverlay: UIView!
    @IBOutlet weak var labelDJRole: UILabel!
    
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
    
    func tapDJ(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            UIView.animateWithDuration(0.3) {
                self.viewDJOverlay.alpha = self.viewDJOverlay.alpha.isZero ? 1 : 0
            }
            
        default:
            break
        }
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
        labelDJRole.text = data.dj.role
        
        data.dj.image { (image) in
            self.imageDJ.image = image
        }
    }
    
    func radioUpdatedTime(currentTime: Int) {
        labelTime.text = player.currentData?.nowPlaying.displayableTime()
    }

}
