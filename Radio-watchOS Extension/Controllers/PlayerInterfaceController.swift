//
//  PlayerInterfaceController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/11/16.
//
//

import WatchKit

class PlayerInterfaceController: WKInterfaceController, ConnectivityDelegate {

    // MARK: Outlets
    
    @IBOutlet var groupContent: WKInterfaceGroup!
    @IBOutlet var labelNothing: WKInterfaceLabel!
    @IBOutlet var imageDJ: WKInterfaceImage!
    @IBOutlet var timerTrack: WKInterfaceTimer!
    @IBOutlet var labelTime: WKInterfaceLabel!
    @IBOutlet var labelTrack: WKInterfaceLabel!
    
    // MARK: - Properties
    
    let connectivity = Connectivity()
    
    // MARK: - Controller
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        connectivity.delegate = self
        connectivity.startSession()
        
        installItens(false)
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // MARK: - Connectivity Delegate
    
    func connectivityUpdatedContext(context: RadioContext) {
        if let isPlaying = context.isPlaying {
            labelNothing.setHidden(isPlaying)
            groupContent.setHidden(!isPlaying)
            
            if !isPlaying {
                timerTrack.stop()
            }
            
            installItens(isPlaying)
        }
        
        if let dj = context.dj, data = dj.imageData {
            let image = UIImage(data: data)
            imageDJ.setImage(image)
        }
        
        if let nowPlaying = context.nowPlaying {
            timerTrack.stop()
            if let startDate = nowPlaying.start {
                timerTrack.setDate(startDate)
                timerTrack.start()
            }
            
            labelTime.setText("/ \(nowPlaying.displayableEndTime())")
            labelTrack.setText(nowPlaying.displayableMetadata())
        }
    }
    
    // MARK: - Menu
    
    func installItens(isPlaying: Bool) {
        clearAllMenuItems()
        
        if isPlaying {
            addMenuItemWithImageNamed("Stop", title: Localized.string("Stop"), action: #selector(PlayerInterfaceController.menuStop))
            return
        }
        
        addMenuItemWithItemIcon(.Play, title: Localized.string("Play"), action: #selector(PlayerInterfaceController.menuPlay))
        addMenuItemWithItemIcon(.Speaker, title: Localized.string("Now Playing"), action: #selector(PlayerInterfaceController.menuNowPlaying))
    }
    
    // MARK: - Actions
    
    func menuPlay() {
        connectivity.sendMethod(.Play)
    }
    
    func menuStop() {
        connectivity.sendMethod(.Stop)
    }
    
    func menuNowPlaying() {
        labelNothing.setText(Localized.string("Loading..."))
        RadioAPI.getData { (data) in
            self.timerTrack.stop()
            
            self.labelNothing.setHidden(true)
            self.groupContent.setHidden(false)
            self.labelNothing.setText(Localized.string("Nothing playing on iPhone"))
            
            if let track = data?.nowPlaying {
                self.timerTrack.setDate(track.start!)
                self.labelTime.setText("/ \(track.displayableEndTime())")
                self.labelTrack.setText(track.displayableMetadata())
            }
            
            if let dj = data?.dj {
                ImageAPI.getDJImage(dj, completion: { (image) in
                    if let imageData = image {
                        self.imageDJ.setImage(UIImage(data: imageData))
                    }
                })
            }
        }
    }

}
