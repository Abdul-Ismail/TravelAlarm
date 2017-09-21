//
//  MapSearchViewController.swift
//  TravelAlarm
//
//  Created by Abdulaziz Ismail on 20/09/2017.
//  Copyright © 2017 Abdulaziz Ismail. All rights reserved.
//

import UIKit
import MapKit

struct Annotations {
    var coords: CLLocationCoordinate2D
    var shortname: String
}

var annotations: [Annotations] = []
var currentUserLocation: CLLocation!

class MapSearchViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var getCurrentLocation: UIButton!
    

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearch: UISearchBar!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var  effect: UIVisualEffect!
  
    //popUpview
    @IBOutlet var pinLocationPopUpView: UIView!
    @IBOutlet weak var pinLocation: UIButton!
    @IBOutlet weak var locationName: UITextField!
    var popUpEnabled = false
    
    var cordTouchedAt: CGPoint!
    
    let manager = CLLocationManager()
    
    var spanToUserLocationOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSearch.delegate = self
        
        //hide affect to disenable blur and allow control on upmost view
        visualEffectView.isHidden = true
        
        //corener radius
        pinLocationPopUpView.layer.cornerRadius = 5
        
        //longpress
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPres))
        longPressGesture.minimumPressDuration = 0.6
        self.mapView.addGestureRecognizer(longPressGesture)

        
         manager.allowsBackgroundLocationUpdates = true
        
        //user location
        if CLLocationManager.locationServicesEnabled() {
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //best accuracy that we can get
        manager.startUpdatingLocation() //update location every time it changes
        self.mapView.showsUserLocation = true
        }else {
            print("error")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAnnotation), name: NSNotification.Name.init("deletePin"), object: nil)
        
    }
    
    
    
    //function thats called everytime the users position changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //extract user location when this function is called
         currentUserLocation = locations[0] //locations will store all location, 0 will store the most recent
        if alarmSet {
         NotificationCenter.default.post(name: NSNotification.Name.init("updateDistance"), object: nil)
            
        }

        
        if spanToUserLocationOnce == false {
            spanToUserLocationOnce = true
            spanToLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
        }

    }
    
    //animate the pop up view
    func animateIn() {
        self.view.addSubview(pinLocationPopUpView)
        pinLocationPopUpView.center = self.view.center
        
        //self.view.isUserInteractionEnabled = false
        //self.pinLocationPopUpView.isUserInteractionEnabled = true
        
        
        //make pop up bigger before we can scale it down and alpha 0
        pinLocationPopUpView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
        pinLocationPopUpView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.isHidden = false
            self.pinLocationPopUpView.alpha = 1
            self.pinLocationPopUpView.transform = CGAffineTransform.identity //original identity
            
        }
        
    }
    
    //animateOut
    func animateOut() {
        UIView.animate(withDuration: 0.4
            , animations: {
                self.pinLocationPopUpView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
                self.pinLocationPopUpView.alpha = 0
        }) { (success: Bool) in
            //perform this once animation is done
            self.pinLocationPopUpView.removeFromSuperview()
            self.visualEffectView.isHidden = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //dismiss keyboard
        view.endEditing(true)
        
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        //start search based on that search request
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (result, error) in
           //remove activity indicator
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if result == nil {
                print("error")
            }else {
               //getting data
                let latitude = result?.boundingRegion.center.latitude
                let longitude = result?.boundingRegion.center.longitude
                
                self.spanToLocation(latitude: latitude!, longitude: longitude!)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //only update cords if user is on map view
        if popUpEnabled == false {
        if let touch = touches.first  {
             cordTouchedAt = touch.location(in: view)
            }
        }
    }
    
    
    func addAnnotationOnLongPres() {
        
        //reset the label value so if user doesnt fill it in it wont be using previosu stored value
        locationName.text = ""
        
        //if statement to avoid function being called mutiple times if user holds for longer period of time
        if popUpEnabled == false {
            mapView.isUserInteractionEnabled = false
            mapSearch.isUserInteractionEnabled = false
            animateIn()
            popUpEnabled = true
        }
    }
    
    @IBAction func pinLocationAction(_ sender: Any) {
        
        let newCoordinate = self.mapView.convert(cordTouchedAt, toCoordinateFrom:self.mapView)
        
        //if user picked a location store that else reverse gecode and get address
        let customName: String
        if locationName.text != "" {
            customName = locationName.text!
        }else {
            //store geocode
            customName = "address picked"
        }
        
        
        annotations.append(Annotations(coords: newCoordinate, shortname: customName))
        
        animateOut()
        mapView.isUserInteractionEnabled = true
        mapSearch.isUserInteractionEnabled = true
        popUpEnabled = false
        
        //pin annotation
        let pinnedAnnotation = MKPointAnnotation()
        pinnedAnnotation.coordinate = newCoordinate
        pinnedAnnotation.title = customName
        mapView.addAnnotation(pinnedAnnotation)
        
        // Create request
        let request = MKDirectionsRequest()
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: newCoordinate, addressDictionary: nil))
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
            } else {
                print(error?.localizedDescription)
            }
        }
        
        //inform pinlocation tab by notification to relaod table view
        NotificationCenter.default.post(name: NSNotification.Name.init("pinAdded"), object: nil)
        
    }
    
    
    func spanToLocation(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpanMake(0.02, 0.02) //how zoomed in
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
    }
    

    
    @IBAction func getCurrentLocationAction(_ sender: Any) {
        spanToLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)

    }
    
    //this function gets called by the deletePin notification
     @objc func deleteAnnotation(notification: Notification) {
        guard var locationOfAnnotationToDelete = notification.object as? String else {
            return print("Did not recieve a object in notification")
        }
        
        //remove all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        //put pin again from the same array, this time one field in the array was deleted so annotations is updated
        for annotation in annotations {
            let pinnedAnnotation = MKPointAnnotation()
            pinnedAnnotation.coordinate = annotation.coords
            pinnedAnnotation.title = annotation.shortname
            mapView.addAnnotation(pinnedAnnotation)
        }

        print(locationOfAnnotationToDelete)
    }

}
