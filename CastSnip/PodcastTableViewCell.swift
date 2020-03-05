//
//  PodcastTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 10/9/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var podcastCover: UIImageView!
    @IBOutlet weak var podcastName: UILabel!
    
    @IBOutlet weak var podcastAuthor: UILabel!
    @IBOutlet weak var podcastInfo: UILabel!
    
    var podcast: Podcast? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
