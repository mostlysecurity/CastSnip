//
//  PodcastListTableViewController.swift
//  CastSnip
//
//  Created by ewuehler on 10/11/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//

import UIKit

class PodcastListTableViewController: UITableViewController {

    var podcast: Podcast? = nil
    var episodes: Array = [Episode]()
    var feedURL: String = ""
    var hasFetched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
    }
    
    func reloadData() {
        self.episodes.removeAll()
        for episode in PodcastData.store.getEpisodes(feedURL) {
            self.episodes.append(episode)
        }
        self.tableView.reloadData()
    }

    @IBAction func refreshPodcastEpisodes(_ sender: Any) {
        print("Refreshing podcast episodes")
        if (hasFetched == true) {
            // Already refreshed once, no need to do it again...
            // TODO: Fix this to be more functional - stopgap for now
            print("already refreshed")
            self.refreshControl?.endRefreshing()
        } else {
            print("go refresh: \(podcast!.feedURL) - \(self.feedURL)")
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                let feed = Feed()
                var urlstr = self.feedURL
                urlstr = urlstr.lowercased()
                let currentFeedURL = URL(string: urlstr)!
                
                feed.parse(url: currentFeedURL, finished:
                    { (success, error) in
                        if (success) {
                            // Do sucessful parse stuff
                            for e in feed.episodes {
                                //print("\(feed.url) = \(e.guid)")
                                PodcastData.store.addEpisode(feedURL: feed.url, episode: e)
                            }
                        } else {
                            // Do failed parse stuff
                            print(error?.localizedDescription ?? "Failed to Parse Feed: \(urlstr)")
                            let alert = UIAlertController(title: "Oops!", message: "Failed to parse the feed at \(currentFeedURL.absoluteString).\n\nError: \(error?.localizedDescription ?? "")", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        self.reloadData()
                        self.hasFetched = true
                }
                )
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.episodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PodcastListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PodcastListTableViewCell else {
            fatalError("The dequeued cell is not an instance of PodcastListTableViewCell")
        }
//        let df = DateFormatter()
//        df.dateFormat = "yyyy.MM.dd"
        let dfm = DateFormatter()
        dfm.dateFormat = "MMMM"
        let episode = self.episodes[indexPath.row]
        cell.episodeTitle.text = episode.title
        
        let (seasonNumber, episodeNumber) = Util.getSeasonAndEpisode(episode.properties)
        let seasonEpisodeStr = Util.createSeasonAndEpisodeString(season: seasonNumber, episode: episodeNumber, short: true) ?? ""
        let dayStr = String(format: "%02d", Calendar.current.component(.day, from: episode.date))
        let monthStr = String(format: "%02d", Calendar.current.component(.month, from:episode.date))
        let monthNameStr = dfm.string(from: episode.date).uppercased()
        let yearStr = String(format: "%04d", Calendar.current.component(.year, from:episode.date))

        // If there is a season and episode, then we want to display those numbers, otherwise, the date
        if (episodeNumber != -1 && seasonNumber != -1) {
            cell.episodeNumberOrDay.text = String(format: "%d", episodeNumber)
            cell.episodeTextOrMonth.text = "EPISODE"
            cell.episodeNote.text = "\(yearStr).\(monthStr).\(dayStr)"
            cell.episodeSeasonOrYear.text = String(format: "SEASON %d", seasonNumber)
        } else {
            cell.episodeNumberOrDay.text = dayStr
            cell.episodeTextOrMonth.text = monthNameStr
            cell.episodeSeasonOrYear.text = "\(yearStr)"
            cell.episodeNote.text = seasonEpisodeStr
        }
        cell.episodeNumberOrDay.backgroundColor = Theme.shared.episodeDateBackgroundColor(episode.date)
        cell.episodeTextOrMonth.backgroundColor = cell.episodeNumberOrDay.backgroundColor
        cell.episodeSeasonOrYear.backgroundColor = UIColor.darkGray

        if (episode.duration > 0) {
            cell.episodeLength.text = Util.calcTime(episode.duration)
        } else {
            cell.episodeLength.text = ""
        }
        cell.episodeIndex = indexPath.row
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "episodeSnipSegue") {

            let episodeIndex = (sender as! PodcastListTableViewCell).episodeIndex

            let viewController = segue.destination as! SnipPodcastViewController
            viewController.feedURL = self.feedURL
            viewController.podcast = self.podcast!
            viewController.episode = self.episodes[episodeIndex]
            
        }
    }

}
