//
//  SetAlarmViewController.swift
//  TravelAlarm
//
//  Created by Abdulaziz Ismail on 20/09/2017.
//  Copyright © 2017 Abdulaziz Ismail. All rights reserved.
//

import UIKit
import MapKit
import AudioToolbox

var pickedLocation: Int? = nil
var alarmSet = false


class SetAlarmViewController: UIViewController {

    
    @IBOutlet weak var pickDestinationLabel: UILabel!
    @IBOutlet weak var setAlarm: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var pickedDistance: UILabel!
    
    @IBOutlet weak var distanceLeft: UILabel!
    
    @IBOutlet weak var pickedLocationLabel: UILabel!
    
    @IBOutlet weak var messageToSetRadius: UILabel!
    @IBOutlet weak var distanceToLocation: UILabel!
    
    @IBOutlet weak var cancel: UIButton!
    
    //stores how far before the stop the user would like to be reminded
    var remindMeBefore = 5000 //random value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //notificaion that pin was added from MapSearchView
        NotificationCenter.default.addObserver(self, selector: #selector(updatePickerView), name: NSNotification.Name.init("pinAdded"), object: nil)
        
        //notifcation that pin has been deleted, updates pickerview
        NotificationCenter.default.addObserver(self, selector: #selector(updatePickerView), name: NSNotification.Name.init("deletePin"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(calculateDistance), name: NSNotification.Name.init("updateDistance"), object: nil)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
       // pickDestinationLabel.text =
        updatePickDestinationLabel()
    }
    
    
    @IBAction func setAlarm_Action(_ sender: Any) {
        //let row = pinnedLocationsPickerView.selectedRow(inComponent: 0)
        alarmSet = true
        remindMeBefore = Int(slider.value)
    
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    //called by NSNotification
    func updatePickerView() {
        updatePickDestinationLabel()
        
    }
    
    func updatePickDestinationLabel() {
        if annotations.count == 0 {
            toggleItems(setState: true)
            pickDestinationLabel.text = "Pin location in Maps first"
        }else if pickedLocation == nil {
             toggleItems(setState: true)
            pickDestinationLabel.text = "Pick location from favourites"
        }else {
            
            toggleItems(setState: false)
            
            pickDestinationLabel.text = "Picked Destination"
            
            pickedLocationLabel.text = annotations[pickedLocation!].shortname
            
            //distance between user and picked location
            var distanceInMeters = calculateDistance()
            if distanceInMeters > 500 {
            slider.maximumValue = Float(500)
            } else {
                slider.maximumValue = Float(distanceInMeters) 
            }
            slider.minimumValue = 1
            slider.setValue(Float(distanceInMeters - 5)/2, animated: true)
            pickedDistance.text = String(slider.value) + " Meterss"
        }
    }
    
    
    //toggle items hidden or unhidden depending on wether the user has picked a location or not
    func toggleItems(setState: Bool) {
        pickedLocationLabel.isHidden = setState
        slider.isHidden = setState
        pickedDistance.isHidden = setState
        distanceLeft.isHidden = setState
        distanceToLocation.isHidden = setState
        messageToSetRadius.isHidden = setState
        setAlarm.isHidden = setState
        cancel.isHidden = setState
        
    }

    @IBAction func sliderAction(_ sender: UISlider) {
        pickedDistance.text = String(sender.value) + " Meters"
        
//        if alarmSet != true {
//            setAlarm.setTitle("SDSD", for: .normal)
//        }
    }

    
    //distance between user and picked location, returns distance, constantly being called as user location ubdates
    func calculateDistance() -> Int{
        //distance between user and picked location
        let coordinate0 = CLLocation(latitude: annotations[pickedLocation!].coords.latitude, longitude: annotations[pickedLocation!].coords.longitude)
        let coordinate1 = CLLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        distanceLeft.text = String(Int(distanceInMeters)) + " Meters"
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
       
   
            if Int(distanceInMeters) < remindMeBefore && alarmSet{
             alertUser()
            }
        
        
        return Int(distanceInMeters)
    }
    
    
    //alerts user once they are in there specified range 
    func alertUser() {
        //reset all daulft settings once location is reached
        cancelledOrAlarmSet()
        
        //alert user to wake up
        
    }
    
    //set states back to default
    func cancelledOrAlarmSet() {
        
    }

    
    
}
