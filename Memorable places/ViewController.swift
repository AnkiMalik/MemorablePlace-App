//
//  ViewController.swift
//  Memorable places
//
//  Created by Ankit Malik on 14/07/18.
//  Copyright © 2018 Ankit Malik. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecogniser:)))
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
        
        if activePlace == -1 {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            
            
        }else {
            // need to get details of active place on the map
            if places.count > activePlace{
                if let name = places[activePlace]["name"]{
                    if let lat = places[activePlace]["lat"]{
                        if let lon = places[activePlace]["lon"]{
                            if let latitude = Double(lat){
                                if let longitude = Double(lon){
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    self.map.setRegion(region, animated: true)
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    annotation.title = name
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }

    @objc func longpress(gestureRecogniser: UIGestureRecognizer){
        if gestureRecogniser.state == UIGestureRecognizerState.began {
        let touchpoint = gestureRecogniser.location(in: self.map)
        let newCoordinates = self.map.convert(touchpoint, toCoordinateFrom: self.map)
        
        var title = ""
        let location = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            else {
                if let placemark = placemarks?[0] {
                    if placemark.subThoroughfare != nil{
                        title += placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        title += placemark.thoroughfare!
                    }
                }
            }
            if title == "" {
                title = "Added \(NSDate())"
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            annotation.title = title
            self.map.addAnnotation(annotation)
            places.append(["name": title, "lat": String(newCoordinates.latitude), "lon": String(newCoordinates.longitude)])
            
             UserDefaults.standard.set(places, forKey: "places")
            
        }
            
        }
      
       
        }
        
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

