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
class TravelLocationViewController : UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var mapView: MKMapView!
    
    //let stack = CoreDataStack()
    var pin : Pin? = nil
    var lat : Double?
    var long: Double?
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.tapRecognizer.delegate = self
        self.mapView.delegate = self
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))

        uilgr.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(uilgr)
//
//        
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        let stack = delegate.stack
//        
//        // Create a fetchrequest
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
//        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              NSSortDescriptor(key: "creationDate", ascending: false)]
        loadPins()
        
        
    }
    
    
    func getFlickrPhotosFromLocation(coordinate: CLLocationCoordinate2D){
        FlickrClient.getFlickrPhotos(latitude: String(coordinate.latitude), longitude: String(coordinate.longitude)) { (error, photoArray) in
            if(error == nil){
                if photoArray!.count < 20{
                    for photo in photoArray!{
                        self.loadPhotos(url: photo.photoUrl)
                    }
                }else{
                    for photo in photoArray![0..<20]{
                        self.loadPhotos(url: photo.photoUrl)
                        //print(photo)
                    }}
            }
            else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func loadPhotos(url:URL){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        FlickrClient.getDataFromUrl(url: url, completion: { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Problem downloading photo from \(url)")
                return
            }
            if let pin = self.pin{
            let photo = Photo(img: data as NSData, context: stack.context)
            photo.pin = pin
            //print("Photo has been created \(photo)")

            }
        })
    
    }
    
    
    
    func loadPins()
    {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
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
                
                //getFlickrPhotosFromLocation(coordinate: annotation.coordinate)
                
                mapView.addAnnotation(annotation)
            }
        }
        
    }
    
//    func downloadImage(url: NSURL)
//    {
//    
//        let request: NSURLRequest = NSURLRequest(url: url as URL)
//        NSURLConnection.send
//        NSURLConnection.sendAsynchronousRequest(
//            request as URLRequest, queue: OperationQueue.main,
//            completionHandler: {(response: URLResponse!,data: Data!,error: NSError!) -> Void in
//                if error == nil {
//                    self.save(index,image: self.TableData[index].image!)
//                    
//                    imageview.image = self.TableData[index].image
//                    
//                }
//        } as! (URLResponse?, Data?, Error?) -> Void)
//        
//    }
    
    func addAnnotation(gestureRecognizer:UILongPressGestureRecognizer){
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = newCoordinates
            
            getFlickrPhotosFromLocation(coordinate: annotation.coordinate)
//            annotation.title = "title"
//            mapView.addAnnotation(annotation)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks![0] 
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = pm.name
                    self.mapView.addAnnotation(annotation)
                    self.pin = Pin(title: annotation.title!, longitude: newCoordinates.longitude.roundTo(places: 5), latitude: newCoordinates.latitude.roundTo(places: 5), context: stack.context)
                    print("Just created a pin: \(self.pin)")
                    print(pm)
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    self.pin = Pin(title: annotation.title!, longitude: newCoordinates.longitude.roundTo(places: 5), latitude: newCoordinates.latitude.roundTo(places: 5), context: stack.context)
                    print("Just created a pin: \(self.pin)")
                    print("Problem with the data received from geocoder")
                }
            })
        }
    
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("PIN WAS tapped")
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pin was selected")
        lat = view.annotation?.coordinate.latitude.roundTo(places: 5)
        long = view.annotation?.coordinate.longitude.roundTo(places: 5)
        print(lat!)
        print(long!)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
//        
//        let pred = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "latitude = %@", self.lat!.roundTo(places:5)), NSPredicate(format: "longitude = %@", self.long!.roundTo(places: 5))])
        
        let pred = NSPredicate(format: "locationName = %@", view.annotation!.title!!)
        
        fr.predicate = pred
        
        let fetchedResults = try? stack.context.fetch(fr) as! [Pin]
        
        self.pin = fetchedResults![0]
        //print("Found pin \(fetchedResults!)")
        performSegue(withIdentifier: "photos", sender: self)
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "photos" {
            
            if let photosVc = segue.destination as? PhotoAlbumViewController {
                photosVc.pin = self.pin!
                // Create FetchedResultsController
//                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath: "humanReadableAge", cacheName: nil)
//                
//                // Inject it into the notesVC
//                notesVC.fetchedResultsController = fc
//                
//                // Inject the notebook too!
//                notesVC.notebook = notebook
            }
        }
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
