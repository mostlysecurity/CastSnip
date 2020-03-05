//
//  Theme.swift
//  CastSnip
//
//  Created by ewuehler on 2/25/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit


class Theme {
    
    static let shared: Theme = Theme()

    enum Name {
        case purple
        case dark
        case black
    }
    
    private var navBarTint: UIColor!
    private var navBarText: UIColor!
    private var audioMeter: UIColor!
    private var tableSectionBackground: UIColor!
    
    
    var current: Name {
        didSet {
            switch (current) {
            case .purple:
                self.setPurpleTheme()
                break
            case .dark:
                self.setDarkTheme()
                break
            case .black:
                self.setBlackTheme()
                break
            }
        }
    }
    
    init() {
        current = .purple
        setPurpleTheme()
    }
    
    func purple() -> UIColor {
        return UIColor(red: (148.0/255.0), green: (55.0/255.0), blue: 1.0, alpha: 1.0)
    }
    
    func white() -> UIColor {
        return UIColor.white
    }
    
    func light() -> UIColor {
        return UIColor.lightGray
    }
    
    func dark() -> UIColor {
        return UIColor.darkGray
    }
    
    func black() -> UIColor {
        return UIColor.black
    }
    
    private func setPurpleTheme() {
        navBarTint = purple()
        navBarText = white()
        audioMeter = purple()
        tableSectionBackground = light()
    }
    
    private func setDarkTheme() {
        navBarTint = dark()
        navBarText = white()
        audioMeter = purple()
        tableSectionBackground = dark()
    }
    
    private func setBlackTheme() {
        navBarTint = black()
        navBarText = white()
        audioMeter = light()
        tableSectionBackground = black()
    }

    func navigationBarTint() -> UIColor {
        return navBarTint
    }
    
    func navigationBarTextColor() -> UIColor {
        return navBarText
    }
    
    func audioMeterColor() -> UIColor {
        return audioMeter
    }
    
    func tableSectionBackgroundColor() -> UIColor {
        return tableSectionBackground
    }
    
    func episodeDateBackgroundColor(_ date: Date) -> UIColor {
        let days: Int = Int(abs(date.timeIntervalSinceNow) / 86400)
        let delta: CGFloat = CGFloat(Float(days)/120.0)
        let color: UIColor = purple()
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let newBrightness = (brightness-delta > 0) ? brightness-delta : 0
//        print("Days: \(days); Delta: \(delta); Hue: \(hue); Sat: \(saturation); Bright: \(brightness); newBright: \(newBrightness)")
        let newColor: UIColor = UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        
        return newColor
    }
}
