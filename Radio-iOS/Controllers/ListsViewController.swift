//
//  ListsViewController.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/18/16.
//
//

import UIKit

private enum ListMode: Int {
    case LastPlayer = 0
    case Queue = 1
}

class ListsViewController: UIViewController, UITableViewDataSource, RadioPlayerDataDelegate {

    // MARK: - Properties
    
    let player = RadioPlayer.sharedPlayer
    private var currentMode: ListMode = .Queue
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableTracks: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.dataDelegate = self
        resetUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Track
    
    func resetUI() {
        tableTracks.alpha = 0
        segmentedControl.alpha = 0
    }
    
    // MARK: - Track
    
    func getTrack(atIndex index: Int) -> Track {
        var tracks = [Track]()
        
        if let data = player.currentData {
            switch currentMode {
            case .LastPlayer:
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
            tableTracks.reloadData()
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = player.currentData {
            switch currentMode {
            case .LastPlayer:
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
            let rounded = Int(interval)
            let totalMinutes = (rounded / 60) % 60
            return String(format: "%02d", totalMinutes)
        }
        
        switch currentMode {
        case .LastPlayer:
            if let date = track.end {
                let interval = date.timeIntervalSinceDate(NSDate())
                cell.labelTime.text = "\(minutesFromInterval(interval)) minutes ago"
            }
            
        case .Queue:
            if let date = track.start {
                let interval = date.timeIntervalSinceDate(NSDate())
                cell.labelTime.text = "in \(minutesFromInterval(interval)) minutes"
            }
        }
        
        return cell
    }
    
    // MARK: - RadioPlayer Data Delegate
    
    func radioUpdatedData(data: RadioData?) {
        tableTracks.reloadData()
    }
    
    func radioIvalidatedData() {
        resetUI()
    }

}
