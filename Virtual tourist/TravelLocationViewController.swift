//
//  TravelLocationViewController.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class TravelLocationViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    

    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.mapView.delegate = self
        var uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))

        uilgr.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(uilgr)
    }
    
    
    func getFlickrPhotosFromLocation(coordinate: CLLocationCoordinate2D){
        FlickrClient.sharedInstance().getFlickrPhotos(latitude: String(coordinate.latitude), longitude: String(coordinate.longitude)) { (error, photoArray) in
            if(error != nil){
            for photo in photoArray!{
                print(photo)
            }
            }
            else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    
    func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            getFlickrPhotosFromLocation(coordinate: annotation.coordinate)
            
            mapView.addAnnotation(annotation)
//            
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                if error != nil {
//                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
//                    return
//                }
//                
//                if (placemarks?.count)! > 0 {
//                    let pm = placemarks![0] 
//                    
//                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title = pm.thoroughfare! + ", " + pm.subThoroughfare!
//                    annotation.subtitle = pm.subLocality
//                    self.mapView.addAnnotation(annotation)
//                    print(pm)
//                }
//                else {
//                    annotation.title = "Unknown Place"
//                    self.mapView.addAnnotation(annotation)
//                    print("Problem with the data received from geocoder")
//                }
//            })
        }
    
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
