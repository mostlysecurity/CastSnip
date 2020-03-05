//
//  TutorialTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/8/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class TutorialTableViewCell: UITableViewCell {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var enjoy: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
