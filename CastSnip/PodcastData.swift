//
//  PodcastDataStore.swift
//  CastSnip
//
//  Created by ewuehler on 10/10/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

class PodcastData {
    
    static let store: PodcastDataStore = PodcastDataStore()
    
    class PodcastDataStore {
//        let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let databaseName = "CastSnip.sqlite"
        var db: OpaquePointer?
        var podcasts: Array<Podcast> = Array<Podcast>()
        var episodes: Array<Episode> = Array<Episode>()
        var snips: Array<Snip> = Array<Snip>()
        
        init() {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(databaseName)
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Podcasts (feedURL TEXT NOT NULL UNIQUE, name TEXT NOT NULL, author TEXT, copyright TEXT, link TEXT, coverData TEXT, properties TEXT);", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Episodes (feedURL TEXT NOT NULL, guid TEXT NOT NULL, title TEXT NOT NULL, link TEXT, author TEXT, summary TEXT, date INTEGER, duration REAL, audioURL TEXT, audioLength INTEGER, audioType TEXT, properties TEXT);", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Snips (guid TEXT NOT NULL, feedURL TEXT NOT NULL, episodeLink TEXT NOT NULL, userNote TEXT NOT NULL, podcastTitle TEXT NOT NULL, episodeName TEXT NOT NULL, startTime REAL NOT NULL, duration REAL NOT NULL, filename TEXT NOT NULL, coverData TEXT, properties TEXT);", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            reloadPodcasts()
        }
        
        private func normalizeFeedURL(_ feedURL: String) -> String {
            return feedURL.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        private func normalizePodcastString(_ string: String) -> String {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        private func encodeImage(_ image: UIImage) -> String {
            if (image.pngData() != nil) {
                return image.pngData()!.base64EncodedString()
            } else {
                return ""
            }
        }
        
        private func decodeImage(_ data: String) -> UIImage {
            let decodedData: Data = Data(base64Encoded: data)!
            let image: UIImage = UIImage(data: decodedData)!
            return image
        }
        
        func reloadPodcasts() {
            podcasts.removeAll()
            let queryString = "select * from Podcasts;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let feedURL = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let author = String(cString: sqlite3_column_text(stmt, 2))
                let copyright = String(cString: sqlite3_column_text(stmt, 3))
                let link = String(cString: sqlite3_column_text(stmt, 4))
                let coverData = String(cString: sqlite3_column_text(stmt, 5))
                let properties = String(cString: sqlite3_column_text(stmt, 6))
                let cover: UIImage = decodeImage(coverData)
                podcasts.append(Podcast(feedURL: feedURL, name: name, author: author, copyright: copyright, link:link, cover:cover, properties:properties))
            }
            sqlite3_finalize(stmt)
            
            for podcast in podcasts {
                let count = getEpisodeCount(for: podcast.feedURL)
                podcast.episodeCount = count
            }
        }
        
        func coverImage(_ feedURL: String) -> UIImage? {
            let queryString = "select coverData from Podcasts where feedURL = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
            }
            
            var cover: UIImage?

            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let coverData = String(cString: sqlite3_column_text(stmt, 0))
                cover = decodeImage(coverData)
            }
            sqlite3_finalize(stmt)
            
            return cover
        }
        
        func getPodcastCount() -> Int {
            return self.podcasts.count
        }
        
        func getPodcast(at: Int) -> Podcast? {
            if self.podcasts.count > at {
                return self.podcasts[at]
            }
            return nil
        }
        
        func getPodcasts() -> Array<Podcast> {
            return self.podcasts
        }
        
        func podcastExists(_ feedURL: String) -> Bool {

            let queryString = "SELECT count(*) as count from Podcasts WHERE feedURL = ?;"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }

            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return false
            }
            
            var count = 0
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                count = Int(sqlite3_column_int(stmt, 0))
                print("count \(count)")
            }
            sqlite3_finalize(stmt)

            return (count > 0)
        }
        
        // Need to throw an exception or something on a failure...
        func addPodcast(name: String, feedURL: String, author: String, copyright: String, link: String, cover: UIImage, properties: String) {
            let feedURL = normalizeFeedURL(feedURL)
            let name = normalizePodcastString(name)
            let author = normalizePodcastString(author)
            let copyright = normalizePodcastString(copyright)
            let link = normalizePodcastString(link)
            let coverData = encodeImage(cover)
            let properties = properties
            
            var stmt: OpaquePointer?
            
            var queryString = ""
            var feedURLIdx:Int32 = 0
            var nameIdx:Int32 = 0
            var authorIdx:Int32 = 0
            var copyrightIdx:Int32 = 0
            var linkIdx:Int32 = 0
            var coverDataIdx:Int32 = 0
            var propertiesIdx:Int32 = 0
            if (podcastExists(feedURL)) {
                queryString = "UPDATE Podcasts SET name = ?, author = ?, copyright = ?, link = ?, coverData = ?, properties = ? WHERE feedURL = ?;"
                nameIdx = 1
                authorIdx = 2
                copyrightIdx = 3
                linkIdx = 4
                coverDataIdx = 5
                propertiesIdx = 6
                feedURLIdx = 7
            } else {
                print("podcast doesn't exist; insert new")
                queryString = "INSERT INTO Podcasts (feedURL, name, author, copyright, link, coverData, properties) VALUES (?,?,?,?,?,?,?);"
                feedURLIdx = 1
                nameIdx = 2
                authorIdx = 3
                copyrightIdx = 4
                linkIdx = 5
                coverDataIdx = 6
                propertiesIdx = 7
            }
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert/update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, feedURLIdx, feedURL, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, nameIdx, name, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, authorIdx, author, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding author: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, copyrightIdx, copyright, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding copyright: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, linkIdx, link, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding link: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, coverDataIdx, coverData, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding cover: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, propertiesIdx, properties, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding properties: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting/updating Podcast: \(errmsg)")
                return
            }
            sqlite3_finalize(stmt)
            
            print("Podcasts saved successfully")
        }
        
        func deletePodcast(_ feedURL: String) {
            
            let queryString = "DELETE from Podcasts WHERE feedURL = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
            }
            
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                print("Deleted \(feedURL)")
            } else {
                print("Did not delete \(feedURL)")
            }
            sqlite3_finalize(stmt)
        }


        func reloadEpisodes() {
            episodes.removeAll()
            let queryString = "select * from Episodes;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }

            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let feedURL = String(cString: sqlite3_column_text(stmt, 0))
                let guid = String(cString: sqlite3_column_text(stmt, 1))
                let title = String(cString: sqlite3_column_text(stmt, 2))
                let link = String(cString: sqlite3_column_text(stmt, 3))
                let author = String(cString: sqlite3_column_text(stmt, 4))
                let summary = String(cString: sqlite3_column_text(stmt, 5))
                let date = Date(timeIntervalSince1970: Double(sqlite3_column_double(stmt, 6)))
                let duration = Double(sqlite3_column_double(stmt, 7))
                let audioURL = String(cString: sqlite3_column_text(stmt, 8))
                let audioLength = Int64(sqlite3_column_int64(stmt, 9))
                let audioType = String(cString: sqlite3_column_text(stmt, 10))
                let properties = String(cString: sqlite3_column_text(stmt, 11))
                
                episodes.append(Episode(feedURL:feedURL, guid:guid, title:title, link:link, author:author, summary:summary, date:date, duration:duration, audioURL:audioURL, audioLength:audioLength, audioType:audioType, properties:properties))
            }
            sqlite3_finalize(stmt)
        }
        

        
        func getEpisodeCount() -> Int {
            return self.episodes.count
        }
        
        func getEpisodeCount(for feedURL: String) -> Int {
            let queryString = "SELECT count(*) as count from Episodes WHERE feedURL = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return 0
            }
            
            var count = 0
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                count = Int(sqlite3_column_int(stmt, 0))
                print("count \(count)")
            }
            sqlite3_finalize(stmt)
            
            return count
        }
        
        func getEpisode(at: Int) -> Episode? {
            if self.episodes.count > at {
                return self.episodes[at]
            }
            return nil
        }
        
        func getEpisodes() -> Array<Episode> {
            return self.episodes
        }
        
        func getEpisodes(_ feedURL: String) -> [Episode] {
            var episodesForFeed: [Episode] = []
            let queryString = "select * from Episodes where feedURL = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let feedURL = String(cString: sqlite3_column_text(stmt, 0))
                let guid = String(cString: sqlite3_column_text(stmt, 1))
                let title = String(cString: sqlite3_column_text(stmt, 2))
                let link = String(cString: sqlite3_column_text(stmt, 3))
                let author = String(cString: sqlite3_column_text(stmt, 4))
                let summary = String(cString: sqlite3_column_text(stmt, 5))
                let date = Date(timeIntervalSince1970: Double(sqlite3_column_double(stmt, 6)))
                let duration = Double(sqlite3_column_double(stmt, 7))
                let audioURL = String(cString: sqlite3_column_text(stmt, 8))
                let audioLength = Int64(sqlite3_column_int64(stmt, 9))
                let audioType = String(cString: sqlite3_column_text(stmt, 10))
                let properties = String(cString: sqlite3_column_text(stmt, 11))
                
                episodesForFeed.append(Episode(feedURL:feedURL, guid:guid, title:title, link:link, author:author, summary:summary, date:date, duration:duration, audioURL:audioURL, audioLength:audioLength, audioType:audioType, properties:properties))
            }
            sqlite3_finalize(stmt)

            return episodesForFeed.sorted(by: { $0.date > $1.date })
        }
        
        func deleteEpisodes(_ feedURL: String) {
            
            let queryString = "DELETE from Episodes WHERE feedURL = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
            }
            
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                print("Deleted Episodes for \(feedURL)")
            } else {
                print("Did not delete Episodes for \(feedURL)")
            }
            sqlite3_finalize(stmt)
        }
        

        
        func episodeExists(feedURL: String, guid: String) -> Bool {
            
            let queryString = "SELECT count(*) as count from Episodes WHERE feedURL = ? and guid = ?;"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return false
            }
            
            if sqlite3_bind_text(stmt, 2, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding guid: \(errmsg)")
                return false
            }
            
            var count = 0
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                count = Int(sqlite3_column_int(stmt, 0))
                print("count \(count)")
            }
            sqlite3_finalize(stmt)

            return (count > 0)
        }
        
        func addEpisode(feedURL: String, episode: Episode) {
            let feedURL = normalizeFeedURL(feedURL)
            
            var stmt: OpaquePointer?
            
            var queryString = ""
            var feedURLIdx:Int32 = 0
            var guidIdx:Int32 = 0
            var titleIdx:Int32 = 0
            var linkIdx:Int32 = 0
            var authorIdx:Int32 = 0
            var summaryIdx:Int32 = 0
            var dateIdx:Int32 = 0
            var durationIdx:Int32 = 0
            var audioURLIdx:Int32 = 0
            var audioLengthIdx:Int32 = 0
            var audioTypeIdx:Int32 = 0
            var propertiesIdx:Int32 = 0
            if (episodeExists(feedURL: feedURL, guid: episode.guid)) {
                print("episode exists; update if necessary")
                queryString = "UPDATE Episodes SET title = ?, link = ?, author = ?, summary = ?, date = ?, duration = ?, audioURL = ?, audioLength = ?, audioType = ?, properties = ? WHERE feedURL = ? and guid = ?;"
                feedURLIdx = 11
                guidIdx = 12
                titleIdx = 1
                linkIdx = 2
                authorIdx = 3
                summaryIdx = 4
                dateIdx = 5
                durationIdx = 6
                audioURLIdx = 7
                audioLengthIdx = 8
                audioTypeIdx = 9
                propertiesIdx = 10
            } else {
                print("episode doesn't exist; insert new")
                queryString = "INSERT INTO Episodes (feedURL, guid, title, link, author, summary, date, duration, audioURL, audioLength, audioType, properties) VALUES (?,?,?,?,?,?,?,?,?,?,?,?);"
                feedURLIdx = 1
                guidIdx = 2
                titleIdx = 3
                linkIdx = 4
                authorIdx = 5
                summaryIdx = 6
                dateIdx = 7
                durationIdx = 8
                audioURLIdx = 9
                audioLengthIdx = 10
                audioTypeIdx = 11
                propertiesIdx = 12
            }
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert/update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, feedURLIdx, normalizeFeedURL(feedURL), -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, guidIdx, episode.guid, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding guid: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, titleIdx, episode.title, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding title: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, linkIdx, episode.link, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding link: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, authorIdx, episode.author, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding author: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, summaryIdx, episode.summary, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding summary: \(errmsg)")
                return
            }
            
            if sqlite3_bind_double(stmt, dateIdx, episode.date.timeIntervalSince1970) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding date: \(errmsg)")
                return
            }
            
            if sqlite3_bind_double(stmt, durationIdx, episode.duration) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding duration: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, audioURLIdx, episode.audioURL, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding audioURL: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int64(stmt, audioLengthIdx, episode.audioLength) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding audioLength: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, audioTypeIdx, episode.audioType, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding audioType: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, propertiesIdx, episode.properties, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding properties: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting/updating Podcast: \(errmsg)")
                return
            }
            sqlite3_finalize(stmt)
            
            print("Episode saved successfully")

        }
        
        func reloadSnips() {
            snips.removeAll()
            let queryString = "select * from Snips;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let guid = String(cString: sqlite3_column_text(stmt, 0))
                let feedURL = String(cString: sqlite3_column_text(stmt, 1))
                let episodeLink = String(cString: sqlite3_column_text(stmt, 2))
                let userNote = String(cString: sqlite3_column_text(stmt, 3))
                let podcastTitle = String(cString: sqlite3_column_text(stmt, 4))
                let episodeName = String(cString: sqlite3_column_text(stmt, 5))
                let startTime = Double(sqlite3_column_double(stmt, 6))
                let duration = Double(sqlite3_column_double(stmt, 7))
                let filename = String(cString: sqlite3_column_text(stmt, 8))
                let coverData = String(cString: sqlite3_column_text(stmt, 9))
                let properties = String(cString: sqlite3_column_text(stmt, 10))
                snips.append(Snip(guid: guid, feedURL: feedURL, episodeLink: episodeLink, userNote: userNote, podcastTitle: podcastTitle, episodeName: episodeName, startTime: startTime, duration: duration, filename: filename, coverData: coverData, properties: properties))
            }
            sqlite3_finalize(stmt)
        }
        
        func getSnipCount() -> Int {
            return self.snips.count
        }
        
        func getSnip(at: Int) -> Snip? {
            if self.snips.count > at {
                return self.snips[at]
            }
            return nil
        }
        
        func getSnips() -> Array<Snip> {
            return self.snips
        }
        
     
        func snipExists(guid: String) -> Bool {
            
            let queryString = "SELECT count(*) as count from Snips WHERE guid = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding guid: \(errmsg)")
                return false
            }
            
            var count = 0
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                count = Int(sqlite3_column_int(stmt, 0))
                print("count \(count)")
            }
            sqlite3_finalize(stmt)
            
            return (count > 0)
        }

        func addSnip(_ snip: Snip) {
            // Need to throw an exception or something on a failure...
            var stmt: OpaquePointer?
            
            var queryString = ""
            var guidIdx:Int32 = 0
            var feedURLIdx:Int32 = 0
            var episodeLinkIdx:Int32 = 0
            var userNoteIdx:Int32 = 0
            var podcastTitleIdx:Int32 = 0
            var episodeNameIdx:Int32 = 0
            var startTimeIdx:Int32 = 0
            var durationIdx:Int32 = 0
            var filenameIdx:Int32 = 0
            var coverDataIdx:Int32 = 0
            var propertiesIdx:Int32 = 0
            
            if (snipExists(guid: snip.guid)) {
                queryString = "UPDATE Snips SET feedURL = ?, episodeLink = ?, userNote = ?, podcastTitle = ?, episodeName = ?, startTime = ?, duration = ?, filename = ?, coverData = ?, properties = ? WHERE guid = ?;"
                guidIdx = 11
                feedURLIdx = 1
                episodeLinkIdx = 2
                userNoteIdx = 3
                podcastTitleIdx = 4
                episodeNameIdx = 5
                startTimeIdx = 6
                durationIdx = 7
                filenameIdx = 8
                coverDataIdx = 9
                propertiesIdx = 10
            } else {
                print("snip doesn't exist; insert new")
                queryString = "INSERT INTO Snips (guid, feedURL, episodeLink, userNote, podcastTitle, episodeName, startTime, duration, filename, coverData, properties) VALUES (?,?,?,?,?,?,?,?,?,?,?);"
                guidIdx = 1
                feedURLIdx = 2
                episodeLinkIdx = 3
                userNoteIdx = 4
                podcastTitleIdx = 5
                episodeNameIdx = 6
                startTimeIdx = 7
                durationIdx = 8
                filenameIdx = 9
                coverDataIdx = 10
                propertiesIdx = 11
            }
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert/update: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, guidIdx, snip.guid, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding guid: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, feedURLIdx, snip.feedURL, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, episodeLinkIdx, snip.episodeLink, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding episodeLink: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, userNoteIdx, snip.userNote, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding userNote: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, podcastTitleIdx, snip.podcastTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding podcastTitle: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, episodeNameIdx, snip.episodeName, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding episodeName: \(errmsg)")
                return
            }
            
            if sqlite3_bind_double(stmt, startTimeIdx, snip.startTime) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding startTime: \(errmsg)")
                return
            }
            
            if sqlite3_bind_double(stmt, durationIdx, snip.duration) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding duration: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, filenameIdx, snip.filename, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding filename: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, coverDataIdx, snip.coverData, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding cover: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, propertiesIdx, snip.properties, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding properties: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting/updating Snip: \(errmsg)")
                return
            }
            sqlite3_finalize(stmt)
            
            print("Snips saved successfully")
        }

        func deleteSnip(guid: String) {
            
            let queryString = "DELETE from Snips WHERE guid = ?;"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing read: \(errmsg)")
            }
            
            if sqlite3_bind_text(stmt, 1, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding feedURL: \(errmsg)")
            }
            
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                print("Deleted \(guid)")
            } else {
                print("Did not delete \(guid)")
            }
            sqlite3_finalize(stmt)
        }
        
        
    }
    
}
