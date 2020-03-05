//
//  PodcastTableViewController.swift
//  CastSnip
//
//  Created by ewuehler on 10/9/18.
//  Copyright © 2018 Eric Wuehler. All rights reserved.
//


import UIKit

class PodcastTableViewController: UITableViewController {
    
    //MARK: Properties
    var podcasts: Array = [Podcast]()
    var snips: Array = [Snip]()
    var showTutorial: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    func reloadData() {
        print("reloading data?")
        PodcastData.store.reloadPodcasts()
        self.podcasts = PodcastData.store.getPodcasts()
        
        PodcastData.store.reloadSnips()
        self.snips = PodcastData.store.getSnips()
        
        self.showTutorial = !Select.setting.hideTutorial()
        
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            if (showTutorial) {
                return CGFloat(44.0)
            } else {
                return CGFloat(0)
            }
        }
        return CGFloat(44.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if (showTutorial) {
                return 1
            } else {
                return 0
            }
        } else if (section == 1) {
            return self.podcasts.count
        } else if (section == 2) {
            return self.snips.count
        }
        return 0
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return ["TUTORIAL","PODCASTS","MY SNIPS"]
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            if (showTutorial) {
                return "TUTORIAL"
            } else {
                return nil
            }
        } else if (section == 1) {
            return "PODCASTS"
        } else if (section == 2) {
            return "MY SNIPS"
        } else {
            return "Wut?"
        }
    }
    
//    override func tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cellIdentifier = "TutorialTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TutorialTableViewCell else {
                fatalError("The dequeued cell is not an instance of TutorialTableViewCell")
            }
            
            return cell
        } else if (indexPath.section == 1) {
            let cellIdentifier = "PodcastTableViewCell"

            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PodcastTableViewCell else {
                fatalError("The dequeued cell is not an instance of PodcastTableViewCell")
            }

            let podcast = self.podcasts[indexPath.row]
            cell.podcast = podcast
            cell.podcastName.text = podcast.name
            cell.podcastCover.image = podcast.cover
            cell.podcastAuthor.text = podcast.author
            
            if (podcast.episodeCount > 1) {
                cell.podcastInfo.text = "\(podcast.episodeCount) Episodes"
            } else if (podcast.episodeCount == 1) {
                cell.podcastInfo.text = "1 Episode"
            } else {
                cell.podcastInfo.text = "No Episodes"
            }
            
            return cell
        } else if (indexPath.section == 2) {
            let cellIdentifier = "SnipTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SnipTableViewCell else {
                fatalError("The dequeued cell is not an instance of SnipTableViewCell")
            }
            let snip = self.snips[indexPath.row]
            cell.snipIndex = indexPath.row
            cell.guid = snip.guid
            cell.cover.image = snip.getCover()
            cell.note.text = snip.podcastTitle
            cell.episode.text = snip.episodeName
            cell.time.text = "\(Util.calcTimeAsString(snip.duration)) @ \(Util.calcTime(snip.startTime))"
            
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            if editingStyle == .delete {
                Select.setting.tutorial(hide: true)
                self.reloadData()
            }
        } else if (indexPath.section == 1) {
            if editingStyle == .delete {
                let cell = self.tableView.cellForRow(at: indexPath) as! PodcastTableViewCell
                self.podcasts.remove(at: indexPath.row)
                PodcastData.store.deletePodcast(cell.podcast!.feedURL)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.reloadData()
            }
        } else if (indexPath.section == 2) {
            if editingStyle == .delete {
                let cell = self.tableView.cellForRow(at: indexPath) as! SnipTableViewCell
                PodcastData.store.deleteSnip(guid: cell.guid)
                self.snips.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.reloadData()
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("Prepare for segue: \(sender) - \(segue.identifier)")
        if (segue.identifier == "episodeListSegue") {
            let feedURL = (sender as! PodcastTableViewCell).podcast!.feedURL
            let podcast = (sender as! PodcastTableViewCell).podcast!
//            print("set the podcast on the list controller: \(sender)")
            let viewController = segue.destination as! PodcastListTableViewController
            viewController.feedURL = feedURL
            viewController.podcast = podcast
        }
        
        if (segue.identifier == "playSnipSegue") {
            
            let snipIndex = (sender as! SnipTableViewCell).snipIndex
            
            let viewController = segue.destination as! SnipPlayerViewController
            //viewController.feedURL = self.feedURL
            viewController.snip = self.snips[snipIndex]
            //viewController.episode = self.episode
            
        }

    }
}
