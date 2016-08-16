//
//  ListsViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/18/16.
//
//

import UIKit

private enum ListMode: Int {
    case LastPlayed = 0
    case Queue = 1
    
    func rowAnimation() -> UITableViewRowAnimation {
        switch self {
        case .LastPlayed:
            return .Right
        case .Queue:
            return .Left
        }
    }
}

class ListsViewController: UIViewController, UITableViewDataSource, RadioPlayerDataDelegate {

    // MARK: - Properties
    
    var elapsedSeconds = 0
    
    let player = RadioPlayer.sharedPlayer
    private var currentMode: ListMode = .Queue
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableTracks: UITableView!
    @IBOutlet weak var segmentedModes: UISegmentedControl!
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.dataDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        elapsedSeconds = 0
        tableTracks.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Track
    
    func getTrack(atIndex index: Int) -> Track {
        var tracks = [Track]()
        
        if let data = player.currentData {
            switch currentMode {
            case .LastPlayed:
                tracks = data.last
                
            case .Queue:
                tracks = data.queue
            }
        }
        
        return tracks[index]
    }
    
    // MARK: - Actions
    
    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        if let mode = ListMode(rawValue: sender.selectedSegmentIndex) {
            currentMode = mode
            tableTracks.reloadSections(NSIndexSet(index: 0), withRowAnimation: mode.rowAnimation())
        }
    }
    
    // MARK: - Gestures
    
    @IBAction func swipeLeft(sender: AnyObject) {
        performGesture(.Queue)
    }
    
    @IBAction func swipeRight(sender: AnyObject) {
        performGesture(.LastPlayed)
    }
    
    private func performGesture(mode: ListMode) {
        if currentMode == mode {
            return
        }
        
        currentMode = mode
        segmentedModes.selectedSegmentIndex = mode.rawValue
        tableTracks.reloadSections(NSIndexSet(index: 0), withRowAnimation: mode.rowAnimation())
    }
    
    // MARK: - TableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = player.currentData {
            switch currentMode {
            case .LastPlayed:
                return data.last.count
                
            case .Queue:
                return data.queue.count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = getTrack(atIndex: indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier(String(TrackCell), forIndexPath: indexPath) as! TrackCell
        
        cell.labelTitle.text = track.song()
        cell.labelArtist.text = track.artist()
        cell.labelTime.text = "-"
        
        func minutesFromInterval(interval: Double) -> String {
            func formatMinutesString(minutes: Int) -> String {
                if minutes == 0 {
                    return "less then a minute"
                }
                
                let normalized = minutes < 0 ? minutes * -1 : minutes
                return String(format: "%02d minute\(normalized == 1 ? "" : "s")", normalized)
            }
            
            let minutes = (Int(interval) / 60) % 60
            let formattedString = formatMinutesString(minutes)
            
            if minutes < 0 {
                return "\(formattedString) ago"
            }
            
            return "in \(formattedString)"
        }
        
        if let date = track.start {
            let interval = date.timeIntervalSinceDate(NSDate())
            cell.labelTime.text = minutesFromInterval(interval)
        }
        
        return cell
    }
    
    // MARK: - RadioPlayer Data Delegate
    
    func radioUpdatedData(data: RadioData?) {
        elapsedSeconds = 0
        tableTracks.reloadData()
    }
    
    func radioUpdatedSecond() {
        if view.window == nil {
            // THIS CONTROLLER IS NOT VISIBLE, DON'T BOTHER UPDATING
            return
        }
        
        elapsedSeconds += 1
        if elapsedSeconds == 60 {
            elapsedSeconds = 0
            tableTracks.reloadData()
        }
    }

}
