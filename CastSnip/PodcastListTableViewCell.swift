//
//  PodcastListTableViewCell.swift
//  CastSnip
//
//  Created by Eric Wuehler on 10/11/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit

class PodcastListTableViewCell: UITableViewCell {

    var episodeIndex: Int = 0
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeLength: UILabel!
    @IBOutlet weak var episodeNote: UILabel!
    @IBOutlet weak var episodeNumberOrDay: UILabel!
    @IBOutlet weak var episodeTextOrMonth: UILabel!
    @IBOutlet weak var episodeSeasonOrYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
