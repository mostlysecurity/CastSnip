//
//  PodcastSearchResult.swift
//  CastSnip
//
//  Created by ewuehler on 2/23/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import Foundation


public class PodcastSearchResult {
    
    var feedURL: String
    var name: String
    var author: String
    var coverURL: String?
    
    init() {
        self.feedURL = ""
        self.name = ""
        self.author = ""
    }
    
}
