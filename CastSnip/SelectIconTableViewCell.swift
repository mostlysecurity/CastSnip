//
//  SelectIconTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/3/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import QuartzCore

class SelectIconTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var purpleContainerView: UIView!
    @IBOutlet weak var purpleImageButton: UIButton!
    
    @IBOutlet weak var darkContainerView: UIView!
    @IBOutlet weak var darkImageButton: UIButton!
    
    @IBOutlet weak var blackContainerView: UIView!
    @IBOutlet weak var blackImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        updateIcon(purpleContainerView, purpleImageButton)
        updateIcon(darkContainerView, darkImageButton)
        updateIcon(blackContainerView, blackImageButton)
        
        let currentIcon = Select.setting.getAppIcon()
        
        if (currentIcon == Select.APPICON_PURPLE) {
            setPurple()
        } else if (currentIcon == Select.APPICON_DARK) {
            setDark()
        } else if (currentIcon == Select.APPICON_BLACK) {
            setBlack()
        } else {
            setPurple()
        }
    }
    
    private func updateIcon(_ container: UIView, _ button: UIButton) {
        
        container.layer.cornerRadius = 10
        container.clipsToBounds = true
        container.layer.borderWidth = 2.0
        container.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true

    }

    private func setSelectedButton(_ container: UIView, _ selected: Bool, _ color: CGColor = UIColor.black.cgColor) {
        
        if (selected) {
            container.layer.borderColor = color
        } else {
            container.layer.borderColor = UIColor.clear.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    func setEnabled(_ enabled: Bool) {
//        titleLabel.isEnabled = enabled
//        detailLabel.isEnabled = enabled
//        purpleImageButton.isEnabled = enabled
//        darkImageButton.isEnabled = enabled
//        blackImageButton.isEnabled = enabled
//        let currentIcon = Select.setting.getAppIcon()
//        if (currentIcon == Select.APPICON_PURPLE) {
//            setSelectedButton(purpleContainerView, true, UIColor.lightGray.cgColor)
//        } else if (currentIcon == Select.APPICON_DARK) {
//            setSelectedButton(darkContainerView, true, UIColor.lightGray.cgColor)
//        } else if (currentIcon == Select.APPICON_BLACK) {
//            setSelectedButton(blackContainerView, true, UIColor.lightGray.cgColor)
//        } else {
//            setSelectedButton(purpleContainerView, true, UIColor.lightGray.cgColor)
//        }
//    }
    
    
    func setPurple() {
        setSelectedButton(purpleContainerView, true)
        setSelectedButton(darkContainerView, false)
        setSelectedButton(blackContainerView, false)
        detailLabel.text = "Purple"
    }
    
    @IBAction func selectedPurple(_ sender: UIButton?) {
        setPurple()
        Select.setting.appIcon(name: Select.APPICON_PURPLE)
    }
    
    func setDark() {
        setSelectedButton(purpleContainerView, false)
        setSelectedButton(darkContainerView, true)
        setSelectedButton(blackContainerView, false)
        detailLabel.text = "Dark"
    }
    
    @IBAction func selectedDark(_ sender: UIButton?) {
        setDark()
        Select.setting.appIcon(name: Select.APPICON_DARK)
    }
    
    func setBlack() {
        setSelectedButton(purpleContainerView, false)
        setSelectedButton(darkContainerView, false)
        setSelectedButton(blackContainerView, true)
        detailLabel.text = "Black"
    }
    
    @IBAction func selectedBlack(_ sender: UIButton?) {
        setBlack()
        Select.setting.appIcon(name: Select.APPICON_BLACK)
    }
    
}
