//
//  Podcast.swift
//  CastSnip
//
//  Created by ewuehler on 10/10/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit


public class Podcast {
    
    var feedURL: String
    var name: String
    var author: String
    var copyright: String
    var link: String
    var cover: UIImage? = UIImage(named: "CastSnipLogoTransparentLightGray")!
    var coverURL: String?
    var properties: String?
    
    var episodeCount: Int = 0
    
    init() {
        self.feedURL = ""
        self.name = ""
        self.author = ""
        self.copyright = ""
        self.link = ""
    }
    
    init(feedURL: String, name: String, author: String, copyright: String, link: String, cover: UIImage?, properties: String?) {
        self.feedURL = feedURL
        self.name = name
        self.author = author
        self.copyright = copyright
        self.link = link
        self.cover = cover
        self.properties = properties
    }
}
