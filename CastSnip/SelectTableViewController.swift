//
//  PremiumTableViewController.swift
//  CastSnip
//
//  Created by ewuehler on 3/2/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import StoreKit
import SwiftOverlays

class SelectTableViewController: UITableViewController {

    var products: [SKProduct] = []

    let ProductID: ProductIdentifier =  CastSnipProducts.SettingsPaymentID
    let ROW_BUY_OR_CANCEL = 0
    let ROW_RESTORE = 1
    
    let ROW_DETAIL = 0
    let ROW_WATERMARK = 1
    let ROW_SEEK_FWD = 2
    let ROW_SEEK_BWD = 3
    let ROW_SEARCH_RESULT = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectTableViewController.handlePurchaseNotification(_:)), name: .CastSnipPaymentPurchaseNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectTableViewController.handleFailedPurchaseNotification(_:)), name: .CastSnipFailedPurchaseNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectTableViewController.handleFailedRestoreNotification(_:)), name: .CastSnipFailedRestoreNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.backBarButtonItem?.title = " "
        
        loadProducts()
    }

    func loadProducts() {
        if (products.count == 0) {
            CastSnipProducts.store.requestProducts { [weak self] success, products in
                guard let self = self else { return }
                if success {
                    self.products = products!
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            self.tableView.reloadData()
        }
    }

    @objc func handlePurchaseNotification(_ notification: Notification) {
        SwiftOverlays.removeAllBlockingOverlays()
        guard
            let productID = notification.object as? String,
            let _ = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
        else { return }
        self.tableView.reloadData()
//        tableView.reloadRows(at: [IndexPath(row: ROW_SUBSCRIBE_OR_CANCEL, section: 0)], with: .fade)
    }
    
    @objc func handleFailedPurchaseNotification(_ notification: Notification) {
        SwiftOverlays.removeAllBlockingOverlays()
        
        let alert = UIAlertController(title: "Oops!", message: "Failed to purchase...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.tableView.reloadData()
    }
    
    @objc func handleFailedRestoreNotification(_ notification: Notification) {
        SwiftOverlays.removeAllBlockingOverlays()
        
        let alert = UIAlertController(title: "Oops!", message: "Failed to restore...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.tableView.reloadData()
    }
    
    func buyProductById(_ productID: ProductIdentifier) {
        let product = getProductById(productID)
        if (product != nil) {
            if (CastSnipProducts.store.isProductPurchased(productID)) {
                // Manage the Subscription
//                restoreProductById(productID)
//                if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:])
//                    }
//                }
            } else {
                SwiftOverlays.showBlockingWaitOverlayWithText("Purchasing...")
                CastSnipProducts.store.buyProduct(product!)
            }
        }
    }
    
    func restoreProductById(_ productID: ProductIdentifier) {
        if (!CastSnipProducts.store.isProductPurchased(productID)) {
            SwiftOverlays.showBlockingWaitOverlayWithText("Restoring previous purchase")
            CastSnipProducts.store.restorePurchases()
        }
    }
    
    func getProductById(_ productID: ProductIdentifier) -> SKProduct? {
        guard let index = products.firstIndex(where: { product -> Bool in
            product.productIdentifier == productID
        }) else {
            print("Invalid productIdentifier: \(productID)")
            return nil
        }
        let product = products[index]
        return product
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat(1.0)
        }
        return CGFloat(44.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else if (section == 1) {
            return 5
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return " "
        } else if (section == 1) {
            return "SELECT SETTINGS"
        }
        return ""
    }
    
    func priceFormatter(_ locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }
    
    func dateFormatter(_ locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = locale
        return formatter
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            if (indexPath.row == ROW_BUY_OR_CANCEL) {
                // Subscribe or Cancel
                let cell = tableView.dequeueReusableCell(withIdentifier: "BuyOrCancelCell", for: indexPath)
                cell.textLabel?.text = "Loading Purchase Information..."
                cell.detailTextLabel?.text = ""
                
                guard let product = getProductById(ProductID) else {
                    return cell
                }
                let pf = priceFormatter(product.priceLocale)
                let priceString = pf.string(from: product.price) ?? "?"
//                let df = dateFormatter(product.priceLocale)

//                if (CastSnipProducts.store.isProductPurchased(ProductID)) {
//                    cell.textLabel?.text = "Change or Cancel Subscription"
////                    let date = Select.setting.subscriptionTransactionDate(ProductID)
////                    if (date != nil) {
////                        cell.detailTextLabel?.text = "Subscribed on \(df.string(from: date!))"
////                    } else {
//                        cell.detailTextLabel?.text = ""
////                    }
//                } else {
                    cell.textLabel?.text = "Purchase"
                    cell.detailTextLabel?.text = "\(priceString)"
//                }
                
                return cell
            } else if (indexPath.row == ROW_RESTORE) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RestoreCell", for: indexPath)
                cell.textLabel?.text = "Restore previous purchase"
                return cell
            }
        } else if (indexPath.section == 1) {
            let enabledRows: Bool = Select.setting.isSubscribed(CastSnipProducts.SettingsPaymentID)
            if (indexPath.row == ROW_DETAIL) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeDetailCell", for: indexPath) as! SelectDetailTableViewCell
                cell.titleLabel.text = "Detail Panel"
                cell.detailLabel.text = "Show \"Episode Detail\" on Snip"
                cell.detailSwitch.isOn = !Select.setting.hideDetail()
                cell.setEnabled(enabledRows)
                return cell
            } else if (indexPath.row == ROW_WATERMARK) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WatermarkCell", for: indexPath) as! SelectWatermarkTableViewCell
                cell.titleLabel.text = "Watermark"
                cell.detailLabel.text = "Show \"Made with Cast/Snip\" on Snip Image"
                cell.watermarkSwitch.isOn = !Select.setting.hideWatermark()
                cell.setEnabled(enabledRows)
                return cell
            } else if (indexPath.row == ROW_SEEK_FWD) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeekCell", for: indexPath)
                
                cell.textLabel?.text = "Seek Forward"
                cell.detailTextLabel?.text = "\(Select.setting.seekForwardAsInt()) Seconds"
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.isEnabled = enabledRows
                cell.detailTextLabel?.isEnabled = enabledRows
                
                return cell
            } else if (indexPath.row == ROW_SEEK_BWD) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeekCell", for: indexPath)
                
                cell.textLabel?.text = "Seek Backward"
                cell.detailTextLabel?.text = "\(Select.setting.seekBackwardAsInt()) Seconds"
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.isEnabled = enabledRows
                cell.detailTextLabel?.isEnabled = enabledRows

                return cell
            } else if (indexPath.row == ROW_SEARCH_RESULT) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
                
                cell.textLabel?.text = "Podcast Search"
                cell.detailTextLabel?.text = "\(Select.setting.searchResults()) Results"
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.isEnabled = enabledRows
                cell.detailTextLabel?.isEnabled = enabledRows

                return cell
            }
        }
        // should never get here
        return UITableViewCell()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            if (indexPath.row == ROW_BUY_OR_CANCEL) {
                buyProductById(ProductID)
            } else if (indexPath.row == ROW_RESTORE) {
                restoreProductById(ProductID)
            }
        } else if (indexPath.section == 1) {
            let enabledRows: Bool = Select.setting.isSubscribed(CastSnipProducts.SettingsPaymentID)
            if (!enabledRows) { return }
            if (indexPath.row == ROW_DETAIL) {
                //NoOp
            } else if (indexPath.row == ROW_WATERMARK) {
                //NoOp
            } else if (indexPath.row == ROW_SEEK_FWD) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectNumberTableViewController") as! SelectNumberTableViewController
                vc.title = "Seek Forward"
                vc.data = [5, 10, 15, 30, 45, 60]
                vc.dataLabel = "Seconds"
                vc.numberType = "seekfwd"
                vc.dataCurrent = Select.setting.seekForwardAsInt()
                
                self.navigationController?.pushViewController(vc, animated: true)

            } else if (indexPath.row == ROW_SEEK_BWD) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectNumberTableViewController") as! SelectNumberTableViewController
                vc.title = "Seek Backward"
                vc.data = [5, 10, 15, 30, 45, 60]
                vc.dataLabel = "Seconds"
                vc.numberType = "seekbwd"
                vc.dataCurrent = Select.setting.seekBackwardAsInt()
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if (indexPath.row == ROW_SEARCH_RESULT) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectNumberTableViewController") as! SelectNumberTableViewController
                vc.title = "Podcast Search"
                vc.data = [25, 50, 75, 100, 150, 200]
                vc.dataLabel = "Results"
                vc.numberType = "searchresult"
                vc.dataCurrent = Select.setting.searchResults()
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
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
