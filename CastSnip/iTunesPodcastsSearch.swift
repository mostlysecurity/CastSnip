//
//  iTunesSearch.swift
//  CastSnip
//
//  Created by Eric Wuehler on 11/11/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import Foundation

public class iTunesPodcastsSearch {

    private var podcasts: Array<PodcastSearchResult> = []
    
    public func search(_ query: String, completionHandler: @escaping (Bool, String, Array<PodcastSearchResult>)->Void) {
        
        guard let searchURL = createURL(query) else {
            completionHandler(false, "createURL failed", self.podcasts)
            return
        }
//        print ("request: \(searchURL)")
        
        let searchTask = URLSession.shared.dataTask(with: searchURL) {
            (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(false, "failed response", self.podcasts)
                return
            }
            guard 200...299 ~= httpResponse.statusCode else {
                completionHandler(false, "failed: \(httpResponse.statusCode)", self.podcasts)
                return
            }
            
            guard let data = data else {
                completionHandler(false, "missing data", self.podcasts)
                return
            }
            do {
                
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                if let json = jsonObject as? [AnyHashable:Any] {
                    
//                    print("\(json)")
//                    let count = json["resultCount"] as! Int
//                    print("Number of Results: \(count)")
                    
                    if let podcastsArr = json["results"] as? [Any] {
                        for podcastAny in podcastsArr {
                            if let podcastData = podcastAny as? [AnyHashable:Any] {
                                let name = podcastData["collectionName"] as? String
                                let artist = podcastData["artistName"] as? String
                                let feedUrl = podcastData["feedUrl"] as? String
                                let coverUrl = podcastData["artworkUrl600"] as? String
//                                print("Podcast: \(name); \(artist); \(feedUrl); \(coverUrl)")
                                let podcast = PodcastSearchResult()
                                podcast.author = artist ?? "N/A"
                                podcast.name = name ?? "N/A"
                                podcast.coverURL = coverUrl
                                podcast.feedURL = feedUrl ?? "N/A"
                                self.podcasts.append(podcast)
                            }
                        }
                    }
                    
                    
                    completionHandler(true, "success", self.podcasts)

                }
                
//                if (error == nil) {
//                    OperationQueue.main.addOperation({ () -> Void in
//                        self.coverImageView.image = UIImage(data: data!)
//                        self.stopSpinner()
//                    })
//                } else {
//                    self.coverImageView.image = errorImage
//                    self.stopSpinner()
//                }
            } catch {
                completionHandler(false, "failed json", self.podcasts)
            }
        }
        searchTask.resume()
    }
    
    private func createURL(_ searchString: String) -> URL? {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "itunes.apple.com"
        comps.path = "/search"
        comps.queryItems = [URLQueryItem(name: "term", value: searchString), URLQueryItem(name: "media", value: "podcast"), URLQueryItem(name: "limit", value: "\(Select.setting.searchResults())")]
        return comps.url
    }
}
