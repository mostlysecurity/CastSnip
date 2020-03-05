//
//  SearchResultTableViewController.swift
//  CastSnip
//
//  Created by Eric Wuehler on 11/12/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit
import SwiftOverlays

class SearchResultTableViewController: UITableViewController, UISearchBarDelegate {

    public var podcasts: Array<PodcastSearchResult> = []
    private let imageLoader = ImageCacheLoader()
//    private let feed: Feed = Feed()
    private var podcastFeedURL: String?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("going away...")
        
        super.viewWillDisappear(animated)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        beginSearch(searchBar)
    }
    
    func beginSearch(_ sender: UISearchBar) {
        guard let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if (searchText == "") {
            return
        }
        self.searchBar.resignFirstResponder()
        
        if (Util.isURL(searchText)) {
            print("search text is a url: \(searchText)")
            findAsFeed(searchText)
        } else {
            startSpinner("Searching for \(searchText)")
            let search = iTunesPodcastsSearch()
            search.search(searchText) {
                (success, message, result) in
                print("success: \(success); \(message)")
                DispatchQueue.main.async {
                    self.podcasts = result
                    self.stopSpinner()
                    self.reloadData()
                    // Update UI
                    if (result.count == 0) {
                        let alert = UIAlertController(title: "Not Found", message: "No Podcast found for search \"\(searchText)\"", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
        }

        
    }
    
    func findAsFeed(_ feedURLString: String) {
        var urlstr = feedURLString
        urlstr = urlstr.lowercased()
        self.podcastFeedURL = urlstr
        let feedURL = URL(string: urlstr)!
        startSpinner("Reading Podcast Feed")
        let feed = Feed()
        feed.parse(url: feedURL, finished:
            { (success, error) in
                stopSpinner()
                if (success) {
                    // Do sucessful parse stuff
                    let podcast = PodcastSearchResult()
                    podcast.author = feed.authors ?? ""
                    podcast.name = feed.title ?? ""
                    podcast.coverURL = feed.imageURL
                    podcast.feedURL = feed.url
                    self.podcasts.append(podcast)
                    self.reloadData()
                } else {
                    // Do failed parse stuff
                    print(error?.localizedDescription ?? "Failed to Parse Feed: \(urlstr)")
                    let alert = UIAlertController(title: "Oops!", message: "Failed to parse the feed at \(feedURL.absoluteString).\n\nError: \(error?.localizedDescription ?? "")", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
        )
        
    }

    func startSpinner(_ text: String) {
        _ = SwiftOverlays.showBlockingTextOverlay(text)
    }
    
    func stopSpinner() {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    

    // MARK: - Table view data source
    
    func reloadData() {
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (podcasts.count == 0) {
            return ""
        } else if (podcasts.count == 1) {
            return "Found the Podcast!"
        } else if (podcasts.count >= Select.setting.searchResults()) {
            return "Showing first \(podcasts.count) results"
        } else if (podcasts.count > 1) {
            return "\(podcasts.count) Podcasts"
        } else {
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (podcasts.count == 0) {
            return CGFloat(0.0)
        }
        return CGFloat(44.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultIdentifier", for: indexPath) as? SearchResultTableViewCell else {
            fatalError("The dequeued cell is not an instance of SearchResultTableViewCell")
        }
        let podcast = podcasts[indexPath.row]
        cell.podcastName?.text = podcast.name
        cell.podcastAuthor?.text = podcast.author
        cell.podcastCover?.image = UIImage(named: "CastSnipLogoTransparentLightGray")
        let coverURL = podcast.coverURL
        if coverURL != nil {
            imageLoader.obtainImageWithPath(imagePath: coverURL!) { (image) in
                // Before assigning the image, check whether the current cell is visible
                if let updateCell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell {
                    updateCell.podcastCover?.image = image
                }
            }
        } else {
            cell.podcastCover?.image = UIImage(named: "CastSnipLogoTransparentLightGray")
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let podcast = podcasts[indexPath.row]
////        cell.isSelected = podcast.added
//    }
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let podcastSearchResult = self.podcasts[indexPath.row]
//        let urlstr = podcastSearchResult.feedURL.lowercased()
//        PodcastData.store.deletePodcast(urlstr)
//        PodcastData.store.deleteEpisodes(urlstr)
//        podcastSearchResult.added = false
//        self.reloadData()
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let podcastSearchResult = self.podcasts[indexPath.row]
        self.startSpinner("Loading \(podcastSearchResult.name)")
//        let cell = tableView.cellForRow(at: indexPath)
        
        let feed = Feed()
        var urlstr = podcastSearchResult.feedURL
        urlstr = urlstr.lowercased()
        let feedURL = URL(string: urlstr)!
        feed.parse(url: feedURL, finished:
            { (success, error) in
                if (success) {
//                    podcastSearchResult.added = true
                    imageLoader.obtainImageWithPath(imagePath: podcastSearchResult.coverURL!) { (image) in
                        // Before assigning the image, check whether the current cell is visible
                        PodcastData.store.addPodcast(name: feed.title ?? "(Unknown Title)", feedURL: feed.url, author: feed.authors ?? "", copyright: feed.copyright ?? "", link: feed.link ?? "", cover: image, properties: "")
                        for e in feed.episodes {
                            PodcastData.store.addEpisode(feedURL: feed.url, episode: e)
                        }
                        self.stopSpinner()
//                        self.reloadData()
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.stopSpinner()
                    // Do failed parse stuff
                    print(error?.localizedDescription ?? "Failed to Parse Feed: \(urlstr)")
                    let alert = UIAlertController(title: "Oops!", message: "Failed to parse the feed at \(feedURL.absoluteString).\n\nError: \(error?.localizedDescription ?? "")", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
        )
        
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing for the segue")
    }

}


