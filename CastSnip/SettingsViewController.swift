//
//  SettingsViewControllerTableViewController.swift
//  CastSnip
//
//  Created by ewuehler on 2/21/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    let ROW_SELECT = 0
    let ROW_FEEDBACK = 1
    let ROW_RATE = 2
    let ROW_APPICON = 3
    let ROW_ABOUT = 4

    let ROW_TUTORIAL = 0
    
    @IBOutlet weak var tableFooterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "APP"
        } else if (section == 1) {
            return "SETUP"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(44.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5
        } else if (section == 1) {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            
            if (indexPath.row == ROW_SELECT) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CastSnipSelectCell", for: indexPath)
                
//                cell.detailTextLabel?.text = "Thank you for trying Cast/Snip!"
                if (CastSnipProducts.store.isProductPurchased(CastSnipProducts.SettingsPaymentID)) {
                    cell.detailTextLabel?.text = "Thank you for purchasing!"
                } else {
                    cell.detailTextLabel?.text = "Purchase Cast/Snip Select"
                }
                
                
                return cell
            } else if (indexPath.row == ROW_FEEDBACK) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendFeedbackCell", for: indexPath)

                return cell
            } else if (indexPath.row == ROW_RATE) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RateCastSnipCell", for: indexPath)
                
                return cell

            } else if (indexPath.row == ROW_APPICON) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as! SelectIconTableViewCell
//                cell.setEnabled(true)
                return cell

            } else if (indexPath.row == ROW_ABOUT) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
                
                return cell
            }

        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTutorialCell", for: indexPath)
                return cell
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.text = "Default"
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            if (indexPath.row == ROW_SELECT) {
                
            } else if (indexPath.row == ROW_FEEDBACK) {
                if MFMailComposeViewController.canSendMail() {
                    let messageBody: String = "<p>Hey Developer,</p><p>I understand that Cast/Snip is not actually a podcast player and if I really wanted a podcast player, I'd use something like Overcast or Castro. That said, I have the following feedback...</p>"
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["feedback@castsnip.com"])
                    mail.setSubject("Cast/Snip Feedback")
                    mail.setMessageBody(messageBody, isHTML: true)
                    self.present(mail, animated: true)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Mail is not configured on this device", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

            } else if (indexPath.row == ROW_RATE) {
                let rateCount = Select.setting.rateCount()
                if (rateCount < 3) {
                    // TODO: Technically, this should not be called here as it may return nothing due to app store review policy
                    SKStoreReviewController.requestReview()
                } else {
                    // Deep-link App Store
                    if let url = URL(string: Select.APPSTORE_WRITE_REVIEW_URL) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }

                }
                Select.setting.rateCount(count: rateCount+1)
            } else if (indexPath.row == ROW_ABOUT) {
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
