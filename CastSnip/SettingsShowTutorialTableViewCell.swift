//
//  SettingsShowTutorialTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/1/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SettingsShowTutorialTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showTutorialSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showTutorialSwitch.isOn = !Select.setting.hideTutorial()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func showTutorialAction(_ sender: Any) {
        Select.setting.tutorial(hide: !showTutorialSwitch.isOn)
    }
}
