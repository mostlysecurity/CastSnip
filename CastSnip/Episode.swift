//
//  Episode.swift
//  CastSnip
//
//  Created by ewuehler on 10/12/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit


class Episode {

    private(set) var feedURL: String = ""
    private(set) var guid: String = ""
    private(set) var title: String = ""
    private(set) var link: String = ""
    private(set) var author: String = ""
    private(set) var summary: String = ""
    private(set) var date: Date = Date()
    private(set) var duration: TimeInterval = 0
    private(set) var audioURL: String = ""
    private(set) var audioLength: Int64 = 0
    private(set) var audioType: String = ""
    private(set) var properties: String = ""

    init() {
        
    }
    
    init(feedURL: String, guid: String, title: String, link: String, author: String, summary: String, date: Date, duration: TimeInterval, audioURL: String, audioLength: Int64, audioType: String, properties: String) {
        self.feedURL = feedURL
        self.guid = guid
        self.title = title
        self.link = link
        self.author = author
        self.summary = summary
        self.date = date
        self.duration = duration
        self.audioURL = audioURL
        self.audioLength = audioLength
        self.audioType = audioType
        self.properties = properties
    }
    
    func setGUID(_ guid: String) {
        self.guid = guid
    }

    func setTitle(_ title: String?) {
        self.title = title ?? "[None]"
    }
    
    func setLink(_ link: String?) {
        self.link = link ?? ""
    }
    
    func setAuthor(_ author: [String?]) {
        for a in author {
            if a != nil {
                self.author = a!
                break
            }
        }
    }
    
    func setSummary(_ summary: [String?]) {
        for s in summary {
            if s != nil {
                self.summary = s!
                break
            }
        }
    }

    func setDate(_ date: Date?) {
        if date != nil {
            self.date = date!
        } else {
            self.date = Date()
        }
    }
    
    func setDuration(_ duration: TimeInterval) {
        self.duration = duration
    }

    func setAudioURL(_ audioURL: String) {
        self.audioURL = audioURL
    }
    
    func setAudioLength(_ audioLength: Int64) {
        self.audioLength = audioLength
    }
    
    func setAudioType(_ audioType: String) {
        self.audioType = audioType
    }
    
    func setProperties(_ properties: String) {
        self.properties = properties
    }
}
