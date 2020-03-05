//
//  AppDelegate.swift
//  CastSnip
//
//  Created by Eric Wuehler on 10/7/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    func makeSureAudioHasStopped() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        makeSureAudioHasStopped()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        makeSureAudioHasStopped()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        makeSureAudioHasStopped()
    }


}

