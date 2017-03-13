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

import CoreData
class TravelLocationViewController : UIViewController {
  
  
  /// MARK: Properties
  var stack : CoreDataStack!
  var pin : Pin? = nil
  var lat : Double?
  var long: Double?
  var dragPin: MKPointAnnotation!
  
  
  /// MARK: Outlets
  @IBOutlet var tapRecognizer: UITapGestureRecognizer!
  @IBOutlet var mapView: MKMapView!
  
  
  /// MARK: Lifecycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    stack = delegate.stack
    
    self.tapRecognizer.delegate = self
    self.mapView.delegate = self
    let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
    
    uilgr.numberOfTouchesRequired = 1
    mapView.addGestureRecognizer(uilgr)
    loadPins()
    
    
  }
  
  //MARK: Overridden methods
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if segue.identifier! == "photos" {
      
      if let photosVc = segue.destination as? PhotoAlbumViewController {
        photosVc.pin = self.pin!
      }
    }
  }
  
}


// MARK: - Private Methods
private extension TravelLocationViewController{
  
  func getFlickrPhotosFromLocation(coordinate: CLLocationCoordinate2D){
    FlickrClient.getFlickrPhotos(latitude: String(coordinate.latitude), longitude: String(coordinate.longitude)) { (error, photoArray) in
      if(error == nil){
        if (photoArray?.isEmpty)!{
          self.getFlickrPhotosFromLocation(coordinate: coordinate)
          return
        }
        else{
          for photo in photoArray!{
            self.loadPhotos(url: photo.photoUrl)
          }
        }
      }
      else{
        self.displayAlert(error!, title: "")            }
    }
    
  }
  
  func loadPhotos(url:URL){
    
    FlickrClient.getDataFromUrl(url: url, completion: { (data, response, error) in
      
      guard let data = data, error == nil else {
        print("Problem downloading photo from \(url)")
        return
      }
      if let pin = self.pin{
        DispatchQueue.main.async{
          let photo = Photo(img: data as NSData, context: self.stack.context)
          photo.pin = pin
        }
        
      }
    })
    
  }
  
  
  
  func loadPins()
  {
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
    
    let fetchedResults = try? stack.context.fetch(fetchRequest) as! [Pin]
    
    if let results = fetchedResults
    {
      for result in results
      {
        let lat = result.value(forKey:"latitude") as! Double
        let long = result.value(forKey: "longitude") as! Double
        let title = result.value(forKey: "locationName") as! String
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = lat
        annotation.coordinate.longitude = long
        annotation.title = title
        
        mapView.addAnnotation(annotation)
      }
    }
    
  }
  
  @objc func addPin(gestureRecognizer:UIGestureRecognizer){
    let touchPoint = gestureRecognizer.location(in: mapView)
    let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    if dragPin != nil {
      dragPin.coordinate = newCoordinates
    }
    if gestureRecognizer.state == UIGestureRecognizerState.began {
      dragPin = MKPointAnnotation()
      dragPin.coordinate = newCoordinates
      dragPin.title = ""
      mapView.addAnnotation(dragPin)
    } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      dragPin.coordinate = newCoordinates
      getFlickrPhotosFromLocation(coordinate: dragPin.coordinate)
      dragPin.title = ""
      //self.mapView.addAnnotation(dragPin)
      // DispatchQueue.main.async{
      self.pin = Pin(title: self.dragPin.title!, longitude: self.dragPin.coordinate.longitude.roundTo(places: 6), latitude: self.dragPin.coordinate.latitude.roundTo(places: 6), context: self.stack.context)
      //}
      getFlickrPhotosFromLocation(coordinate: dragPin.coordinate)
      dragPin = nil
    }
  }
  
  
}


extension TravelLocationViewController: UIGestureRecognizerDelegate{
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}




extension TravelLocationViewController :MKMapViewDelegate{
  
  //    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
  //                 calloutAccessoryControlTapped control: UIControl) {
  //        print("PIN WAS tapped")
  //    }
  
  
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    mapView.deselectAnnotation(view.annotation, animated: true)
    
    lat = view.annotation?.coordinate.latitude
    long = view.annotation?.coordinate.longitude
    
    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
    
    fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    let pred = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "latitude = %lf", self.lat!.roundTo(places:6)), NSPredicate(format: "longitude = %lf", self.long!.roundTo(places: 6))])
    
    //let pred = NSPredicate(format: "locationName = %@", view.annotation!.title!!)
    
    fr.predicate = pred
    
    let fetchedResults = try? stack.context.fetch(fr) as! [Pin]
    
    if let pin = fetchedResults?[0]{
      self.pin = pin
    }else{
      displayAlert("Pin was not found.", title: "Error")
    }
    performSegue(withIdentifier: "photos", sender: self)
  }
  
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    if pinView == nil {
      pinView?.canShowCallout = false
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }
    
    return pinView
  }
  
  
  
}



extension Double {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
