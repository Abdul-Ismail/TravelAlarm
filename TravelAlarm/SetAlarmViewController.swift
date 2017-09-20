//
//  SetAlarmViewController.swift
//  TravelAlarm
//
//  Created by Abdulaziz Ismail on 20/09/2017.
//  Copyright © 2017 Abdulaziz Ismail. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pinnedLocationsPickerView: UIPickerView!
    
    @IBOutlet weak var setAlarm: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notificaion that pin was added from MapSearchView
        NotificationCenter.default.addObserver(self, selector: #selector(updatePickerView), name: NSNotification.Name.init("pinAdded"), object: nil)
        
        //notifcation that pin has been deleted, updates pickerview
        NotificationCenter.default.addObserver(self, selector: #selector(updatePickerView), name: NSNotification.Name.init("deletePin"), object: nil)

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return annotations[row].shortname
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return annotations.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        print(pinnedLocations[row])
//    }
    
    @IBAction func setAlarm_Action(_ sender: Any) {
        let row = pinnedLocationsPickerView.selectedRow(inComponent: 0)
        print(annotations[row].shortname)
    }
    
    //called by NSNotification
    func updatePickerView() {
        self.pinnedLocationsPickerView.reloadAllComponents()
    }
    
    

    
    
    
    
    
    
    

}
