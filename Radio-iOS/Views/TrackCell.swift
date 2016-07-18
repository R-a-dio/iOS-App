//
//  TrackCell.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/18/16.
//
//

import UIKit

class TrackCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    // MARK: - Cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
