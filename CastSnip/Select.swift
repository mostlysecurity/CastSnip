//
//  UserProperties.swift
//  CastSnip
//
//  Created by ewuehler on 3/4/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit


class Select {
    
    static let APPICON_PURPLE: String = "purple"
    static let APPICON_DARK: String = "dark"
    static let APPICON_BLACK: String = "black"
    
    static let DEFAULT_SEEK_STEP: Double = 10.0
    
    static let DEFAULT_SEARCH_RESULTS: Int = 25
    static let APPSTORE_WRITE_REVIEW_URL: String = "itms-apps://itunes.apple.com/us/app/cast-snip/id1439722076?mt=8&action=write-review"
    
    private static let DETAIL: String = "detail"
    private static let WATERMARK: String = "watermark"
    private static let APPICON: String = "appicon"
    private static let SEEKBACK: String = "seekback"
    private static let SEEKFWD: String = "seekfwd"
    private static let SEARCHRESULTS: String = "searchresults"
    
    private static let TUTORIAL: String = "tutorial"
    private static let RATE_COUNT: String = "ratecount"
    
    static let setting: Select = Select()
    
    
    func addSubscription(_ identifier: ProductIdentifier, transaction date: Date?) {
        UserDefaults.standard.set(true, forKey: identifier)
        if (date != nil) {
            UserDefaults.standard.set(date?.timeIntervalSince1970, forKey: "\(identifier).TransactionDate")
        } else {
            UserDefaults.standard.set(0, forKey:"\(identifier).TransactionDate")
        }
    }
    
    func isSubscribed(_ identifier: ProductIdentifier) -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return UserDefaults.standard.bool(forKey: identifier)
        #endif
    }
    
    func subscriptionTransactionDate(_ identifier: ProductIdentifier) -> Date? {
        let timeInterval = UserDefaults.standard.double(forKey: "\(identifier).TransactionDate")
        if (timeInterval == 0) {
            return nil
        } else {
            return Date(timeIntervalSince1970: timeInterval)
        }
    }
    
    func detail(hide: Bool) {
        UserDefaults.standard.set(hide, forKey: Select.DETAIL)
    }
    
    func hideDetail() -> Bool {
        return UserDefaults.standard.bool(forKey: Select.DETAIL)
    }
    
    func watermark(hide: Bool) {
        UserDefaults.standard.set(hide, forKey: Select.WATERMARK)
    }
    
    func hideWatermark() -> Bool {
        return UserDefaults.standard.bool(forKey: Select.WATERMARK)
    }
    
    func appIcon(name: String) {
//        UserDefaults.standard.set(name, forKey: Select.APPICON)
        UIApplication.shared.setAlternateIconName(name) { (error) in
            if let error = error {
                print("error setting app icon: \(error)")
            }
        }
    }
    
    func getAppIcon() -> String {
        if (UIApplication.shared.supportsAlternateIcons) {
            return UIApplication.shared.alternateIconName ?? Select.APPICON_PURPLE
        }
        return Select.APPICON_PURPLE
//        return UserDefaults.standard.string(forKey: Select.APPICON) ?? Select.APPICON_PURPLE
    }
    
    func rateCount(count: Int) {
        UserDefaults.standard.set(count, forKey:Select.RATE_COUNT)
    }
    
    func rateCount() -> Int {
        return UserDefaults.standard.integer(forKey: Select.RATE_COUNT)
    }
    
    func seekForward(time: Double) {
        UserDefaults.standard.set(time, forKey:Select.SEEKFWD)
    }
    
    func seekForward() -> Double {
        let fwd = UserDefaults.standard.double(forKey: Select.SEEKFWD)
        if (fwd == 0) {
            seekForward(time: Select.DEFAULT_SEEK_STEP)
            return Select.DEFAULT_SEEK_STEP
        }
        return fwd
    }
    
    func seekForwardAsInt() -> Int {
        return Int(seekForward())
    }
    
    func seekBackward(time: Double) {
        UserDefaults.standard.set(time, forKey:Select.SEEKBACK)
    }
    
    func seekBackward() -> Double {
        let bwd = UserDefaults.standard.double(forKey: Select.SEEKBACK)
        if (bwd == 0) {
            seekBackward(time: Select.DEFAULT_SEEK_STEP)
            return Select.DEFAULT_SEEK_STEP
        }
        return bwd
    }
    
    func seekBackwardAsInt() -> Int {
        return Int(seekBackward())
    }

    func searchResults(max: Int) {
        UserDefaults.standard.set(max, forKey: Select.SEARCHRESULTS)
    }
    
    func searchResults() -> Int {
        let sr = UserDefaults.standard.integer(forKey: Select.SEARCHRESULTS)
        if (sr == 0) {
            searchResults(max: Select.DEFAULT_SEARCH_RESULTS)
            return Select.DEFAULT_SEARCH_RESULTS
        }
        return sr
    }
    
    func tutorial(hide: Bool) {
        UserDefaults.standard.set(hide, forKey: Select.TUTORIAL)
    }
    
    func hideTutorial() -> Bool {
        return UserDefaults.standard.bool(forKey: Select.TUTORIAL)
    }
}
