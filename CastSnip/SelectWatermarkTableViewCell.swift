//
//  SelectWatermarkTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/3/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SelectWatermarkTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var watermarkSwitch: UISwitch!
    
    
    @IBAction func watermarkSwitchTouched(_ sender: UISwitch) {
        Select.setting.watermark(hide: !sender.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        watermarkSwitch.isOn = !Select.setting.hideWatermark()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setEnabled(_ enabled: Bool) {
        self.titleLabel.isEnabled = enabled
        self.detailLabel.isEnabled = enabled
        self.watermarkSwitch.isEnabled = enabled
    }
}
