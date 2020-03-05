//
//  ConfigureViewController.swift
//  CastSnip
//
//  Created by ewuehler on 2/15/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class ConfigureViewController: UIViewController {

    
    @IBOutlet weak var deleteEntireDatabase: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func deleteEntireDatabasePressed(_ sender: Any) {

        let podcasts = PodcastData.store.getPodcasts()
        for podcast in podcasts {
            PodcastData.store.deletePodcast(podcast.feedURL)
            PodcastData.store.deleteEpisodes(podcast.feedURL)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
