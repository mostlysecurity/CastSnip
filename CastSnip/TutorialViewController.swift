//
//  TutorialViewController.swift
//  CastSnip
//
//  Created by ewuehler on 3/9/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import QuartzCore   

class TutorialViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 6.0
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = CGFloat(2.0)
        imageView.layer.borderColor = UIColor.black.cgColor
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
