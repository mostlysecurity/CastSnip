//
//  FeedParser.swift
//  CastSnip
//
//  Created by Eric Wuehler on 10/12/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import Foundation
import FeedKit


class Feed {
    
    private(set) var url: String = ""
    private(set) var title: String? = nil
    private(set) var authors: String? = nil
    private(set) var copyright: String? = nil
    private(set) var link: String? = nil
    private(set) var imageURL: String? = nil
    private(set) var episodes: Array<Episode> = [Episode]()
    
    
    func parse(url: URL, finished: (Bool, Error?) -> Void) {
        self.url = url.absoluteString
        let parser = FeedParser(URL: url)
        let result = parser.parse()
        
        if (result.isFailure) {
            finished(false, result.error)
        } else if (result.isSuccess) {
            switch result {
            case .atom:       // Atom Syndication Format Feed Model
                parseAtomFeed(feed: result.atomFeed)
                break
            case .rss:        // Really Simple Syndication Feed Model
                parseRSSFeed(feed: result.rssFeed)
                break
            case .json:       // JSON Feed Model
                parseJSONFeed(feed: result.jsonFeed)
                break
            case .failure:
                finished(false, result.error)
                break
            }
            finished(true, nil)
        }
        
    }
    
    private func parseAtomFeed(feed: AtomFeed?) {
        self.title = feed?.title!
    }
    
    private func parseRSSFeed(feed: RSSFeed?) {
        self.title = feed?.title!
        self.authors = feed?.iTunes?.iTunesAuthor
        self.copyright = feed?.copyright
        self.link = feed?.link
        if (feed?.image?.url != nil) {
            self.imageURL = feed?.image?.url
        } else if (feed?.iTunes?.iTunesImage?.attributes?.href != nil) {
            self.imageURL = feed?.iTunes?.iTunesImage?.attributes?.href
        }
        
        for item in (feed?.items)! {
            let e: Episode = Episode()
            e.setGUID((item.guid?.value)!)
            e.setTitle(item.title)
            e.setLink(item.link)
            e.setAuthor([item.author, item.iTunes?.iTunesAuthor])
            e.setSummary([item.iTunes?.iTunesSummary, item.description, item.content?.contentEncoded])
            e.setDate(item.pubDate)
            e.setDuration(item.iTunes?.iTunesDuration ?? -1)
            let season = item.iTunes?.iTunesSeason ?? -1
            let episode = item.iTunes?.iTunesEpisode ?? -1
            let propdict = ["season":season,"episode":episode]
            let properties = Util.encodeProperties(propdict)
            e.setProperties(properties)
            if (item.enclosure != nil) {
                e.setAudioURL((item.enclosure?.attributes?.url)!)
                e.setAudioLength((item.enclosure?.attributes?.length) ?? -1)
                e.setAudioType(item.enclosure?.attributes?.type ?? "")
            }
            episodes.append(e)
        }
    }
    
    private func parseJSONFeed(feed: JSONFeed?) {
        self.title = feed?.title!
    }
    
    

}
