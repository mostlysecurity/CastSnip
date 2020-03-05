//
//  SelectDetailTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/9/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SelectDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailSwitch: UISwitch!
    
    @IBAction func detailSwitchTouched(_ sender: UISwitch) {
        Select.setting.detail(hide: !sender.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailSwitch.isOn = !Select.setting.hideDetail()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setEnabled(_ enabled: Bool) {
        self.titleLabel.isEnabled = enabled
        self.detailLabel.isEnabled = enabled
        self.detailSwitch.isEnabled = enabled
    }

}
