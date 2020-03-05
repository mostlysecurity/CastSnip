//
//  SnipPlayerViewController.swift
//  CastSnip
//
//  Created by ewuehler on 1/3/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SnipPlayerViewController: UIViewController, AVPlayerViewControllerDelegate {
    
    
    var feedURL: String!
    var episode: Episode!
    var snip: Snip!
    var videoURL: URL!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var playerViewContainer: UIView!
    
    var playerViewController: AVPlayerViewController!

        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Snip Player"
        
        self.videoURL = Util.videoSnipURL(snip.filename)
        let player = AVPlayer(url: videoURL)
        self.playerViewController.player = player
//        self.playerViewController.player!.play()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pvc = destination as? AVPlayerViewController {
            playerViewController = pvc
            playerViewController.delegate = self
            print("segue has been set")
        }
    }
    
    @objc func doneTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        guard let video = self.videoURL else { return }
        let shareView = UIActivityViewController(activityItems: [video], applicationActivities: nil)
        self.present(shareView, animated: true, completion: {
            print("Share sheet...")
        })
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Snip", message: "Are you sure you want to delete this Snip?", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
            PodcastData.store.deleteSnip(guid: self.snip.guid)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
}
