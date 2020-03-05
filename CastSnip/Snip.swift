//
//  Snip.swift
//  CastSnip
//
//  Created by ewuehler on 1/1/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

public class Snip {

    var guid: String
    var feedURL: String
    var episodeLink: String
    var userNote: String
    var podcastTitle: String
    var episodeName: String
    var startTime: Double
    var duration: Double
    var filename: String
    var coverData: String
    var properties: String
    private var cover: UIImage?

    init() {
        self.guid = ""
        self.feedURL = ""
        self.episodeLink = ""
        self.userNote = ""
        self.podcastTitle = ""
        self.episodeName = ""
        self.startTime = 0
        self.duration = 0
        self.filename = ""
        self.coverData = ""
        self.cover = nil
        self.properties = ""
    }
    
    init(guid: String, feedURL: String, episodeLink: String, userNote: String, podcastTitle: String, episodeName: String, startTime: Double, duration: Double, filename: String, coverData: String, properties: String) {
        self.guid = guid
        self.feedURL = feedURL
        self.episodeLink = episodeLink
        self.userNote = userNote
        self.podcastTitle = podcastTitle
        self.episodeName = episodeName
        self.startTime = startTime
        self.duration = duration
        self.filename = filename
        self.coverData = coverData
        self.cover = nil
        self.properties = properties
    }
    
    
    func getCover() -> UIImage {
        if (self.cover == nil) {
            if (self.coverData != "") {
                self.cover = Util.decodeArtwork(self.coverData)
            } else {
                self.cover = UIImage(named: "CastSnipLogoTransparentLightGray")!
            }
        }
        return self.cover!
    }
    
}
