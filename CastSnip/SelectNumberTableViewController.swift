//
//  SelectNumberTableViewController.swift
//  CastSnip
//
//  Created by ewuehler on 3/5/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit

class SelectNumberTableViewController: UITableViewController {

    var data: [Int] = []
    var dataLabel: String = ""
    var dataCurrent: Int = 0
    var numberType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath)

        let dataValue = data[indexPath.row]
        cell.textLabel?.text = "\(dataValue) \(dataLabel)"
        if (dataValue == dataCurrent) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataCurrent = data[indexPath.row]
        
        if (numberType == "seekfwd") {
            Select.setting.seekForward(time: Double(dataCurrent))
        } else if (numberType == "seekbwd") {
            Select.setting.seekBackward(time: Double(dataCurrent))
        } else if (numberType == "searchresult") {
            Select.setting.searchResults(max: dataCurrent)
        }
        
        tableView.reloadData()
        
        self.navigationController?.popViewController(animated: true)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    
        print("returning to view controller")
        
    }

}
