//
//  PinnedLocationsTableViewController.swift
//  TravelAlarm
//
//  Created by Abdulaziz Ismail on 20/09/2017.
//  Copyright © 2017 Abdulaziz Ismail. All rights reserved.
//

import UIKit

class PinnedLocationsTableViewController: UITableViewController {
    
    //var pickedLocation: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notificaion that pin was added from MapSearchView
        NotificationCenter.default.addObserver(self, selector: #selector(add), name: NSNotification.Name.init("pinAdded"), object: nil)

    }
    
    //notification calls this funcuton
    @objc func add(notification: Notification) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return annotations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocations", for: indexPath) as? PinnedLocationTableViewCell else {
            fatalError("The dequeued cell is not an instance of SearchCell.")
        }

        cell.pinLocation.text = annotations[indexPath.row].shortname

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {

        //removing before we send the notification
        annotations.remove(at: indexPath.row)
            
         //send notification that a pin has been deleted
         NotificationCenter.default.post(name: NSNotification.Name.init("deletePin"), object: "annotations[indexPath.row].coords")
            
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //savedStopClickedOn
        pickedLocation = indexPath.row
        tabBarController?.selectedIndex = 1
    }
        
        
    }
    
    //This function is run before savedStopCLickedOn Segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var SetAlarmViewController = segue.destination as! SetAlarmViewController
//        SetAlarmViewController.pickedLocation = pickedLocation
//    }

    
    //this function is run before we perform the segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var DueTimeTableViewController = segue.destination as! DueTimeTableViewController
//        DueTimeTableViewController.checkBusStop = pressedBusStop
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var DueTimeTableViewController = segue.destination as! DueTimeTableViewController
//        DueTimeTableViewController.checkBusStop = pressedBusStop
//    }
//




