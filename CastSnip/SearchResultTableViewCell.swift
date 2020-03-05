//
//  SearchResultTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 2/23/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var podcastCover: UIImageView!
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var podcastAuthor: UILabel!
    
    var podcast: PodcastSearchResult? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
