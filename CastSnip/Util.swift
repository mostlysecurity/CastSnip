//
//  Util.swift
//  CastSnip
//
//  Created by ewuehler on 11/13/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit
import CommonCrypto

class Util {
    
    static func uuidString() -> String {
        return UUID().uuidString
    }
    
    static func isURL (_ urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    static func tempFileURL(_ pathExtension: String) -> URL {
        let pathComponent = "\(UUID().uuidString).\(pathExtension)"
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(pathComponent) as URL
        return tmp
    }

    static func videoSnipURL(_ filename: String) -> URL {
        let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoPathURL = documentsPathURL.appendingPathComponent(filename)
        return videoPathURL
    }
    
    static func podcastLocalURL(podcastName: String, episodeGUID: String, audioExtension: String) -> URL {
        let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localDirs = documentsPathURL.appendingPathComponent("Episodes").appendingPathComponent(podcastName)
        do {
            try FileManager.default.createDirectory(at: localDirs, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        // Some episodeGUIDs are URLs, some are UUIDs, not all have "file safe" characters,
        // so to make sure the file can be saved we create an MD5 digest of the GUID
        let episodeDigest = episodeGUID.md5
        let localURL = localDirs.appendingPathComponent(episodeDigest).appendingPathExtension(audioExtension)
        return localURL
    }

    static func localFileExists(_ filename: URL) -> Bool {
        let fileManager = FileManager.default
        if (filename.isFileURL) {
            return fileManager.fileExists(atPath: filename.path)
        } else {
            return false
        }
    }
    
    // Returns Base64 encoded image data
    static func encodeArtwork(_ artimg: UIImage) -> String {
        return artimg.pngData()!.base64EncodedString()
    }
    
    // Returns UIImage from Base64 encoded image data
    static func decodeArtwork(_ artdata: String) -> UIImage {
        let artworkData: Data = Data(base64Encoded: artdata)!
        return UIImage(data: artworkData)!
    }
    
    // Encode the bonus properties string to JSON
    static func encodeProperties(_ dict: [String:Any]) -> String {
        if (dict.isEmpty) {
            return ""
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString ?? ""
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    // Decode the bonus properties string from JSON
    static func decodeProperties(_ jsonString: String) -> [String:Any] {
        if (jsonString == "" || jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            return [:]
        }
        do {
            let jsonData = jsonString.data(using: .utf8)
            let decoded = try JSONSerialization.jsonObject(with: jsonData ?? Data(), options: [])
            if decoded is [String:Any] {
                return decoded as! [String:Any]
            }
        } catch {
            print(error.localizedDescription)
        }
        return [:]
    }

    static func getSeasonAndEpisode(_ properties: String) -> (Int, Int) {
        let propdict = Util.decodeProperties(properties)
        var result:(Int,Int) = (-1,-1)
        if (!propdict.isEmpty) {
            var season = -1
            var episode = -1
            if (propdict["season"] != nil) {
                season = propdict["season"] as! Int
            }
            if (propdict["episode"] != nil) {
                episode = propdict["episode"] as! Int
            }
            result = (season, episode)
        }
        return result
    }
    
    static func createSeasonAndEpisodeString(season: Int, episode: Int, short: Bool = true) -> String? {
        var result:String?
        
        var seasonStr = "SEASON "
        var episodeStr = "EPISODE "
        if (short) {
            seasonStr = "S"
            episodeStr = "E"
        }
        
        if (season == -1) {
            if (episode == -1) {
                result = nil
            } else {
                result = "EPISODE \(episode)"
            }
        } else {
            if (episode == -1) {
                result = "SEASON \(season)"
            } else {
                result = "\(seasonStr)\(season), \(episodeStr)\(episode)"
            }
        }
        return result
    }
    
    
    static func calcTimeAsString(_ time: Double, short: Bool = false) -> String {
        var min = "minute"
        var mins = "minutes"
        var sec = "second"
        var secs = "seconds"
        if (short) {
            min = "min"
            mins = "min"
            sec = "sec"
            secs = "sec"
        }
        
        let t = Int64(time)
        let hours = t / 3600
        if (hours > 0) {
            return Util.calcTime(time)
        }
        let minutes = (t % 3600) / 60
        let seconds = (t % 3600) % 60
        let minuteString = (minutes == 1) ? min : mins
        let secondString = (seconds == 1) ? sec : secs
        if minutes > 0 {
            if seconds < 2 {
                return "\(minutes) \(minuteString)"
            } else {
                return "\(minutes) \(minuteString) \(seconds) \(secondString)"
            }
        } else {
            if seconds < 2 && !short {
                return "about a second"
            } else {
                return "\(seconds) \(secondString)"
            }
        }
    }
    
    static func calcTime(_ time: Double) -> String {
        return calcTime(time, millis: false)
    }
    
    static func calcTime(_ time: Double, millis: Bool) -> String {
        return calcTime(time, millis: millis, negate: false)
    }
    
    static func calcTime(_ time: Double, millis: Bool, negate: Bool) -> String {
        
        let remainder = Int((time.truncatingRemainder(dividingBy: 1)*10))
        let decimal = Double(remainder) / 10
        
        let t = Int64(time)
        let hours =  t / 3600
        let minutes = (t % 3600) / 60
        let seconds = (t % 3600) % 60
        
        var len = ""
        if (negate && time > 0) {
            len += "-"
        }
        if hours > 0 {
            len += "\(hours):"
        }
        len += (minutes < 10 && hours > 0) ? "0\(minutes):" : "\(minutes):"
        len += (seconds < 10) ? "0\(seconds)" : "\(seconds)"
        if (millis) {
            len += String(format: "%.1f", decimal).dropFirst()
        }
        return len
    }
 
    
    static func showMessage(_ message: String, title: String?) -> UIAlertController {
        let alert = UIAlertController(title: (title ?? "Random Message"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}

extension String {
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = self.data(using: .utf8) {
            _ = d.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                return ""
            }
        }
        
        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
}

