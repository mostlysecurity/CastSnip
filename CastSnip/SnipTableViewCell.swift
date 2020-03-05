//
//  SnipTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 1/1/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SnipTableViewCell: UITableViewCell {

    
    var snipIndex: Int = 0
    var guid: String = ""
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var note: UILabel! // This will be the podcast name if it is not editing with another note
    @IBOutlet weak var episode: UILabel!
    @IBOutlet weak var time: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
