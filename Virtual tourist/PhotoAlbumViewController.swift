//
//  PhotoAlbumViewController.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
class PhotoAlbumViewController :UIViewController {
    
    
    @IBOutlet var mapView: MKMapView!
    
  
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var newCollectionButton: UIBarButtonItem!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollection(_ sender: UIBarButtonItem) {
        imageCache = []
        removePhotos()
        collectionView.reloadData()
        let coordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
        getFlickrPhotosFromLocation(coordinate: coordinate)
    }
    
    
    // MARK: Properties
    
    var photos: [Photo] = []
    var pin : Pin?
    var stack : CoreDataStack!
    var imageCache: [Data] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        fillImageCache()
        stack = delegate.stack
        mapView.delegate = self
        collectionView.delegate = self
        loadPhotos()
        addAnnotation()
        
    }
    
    func fillImageCache(){
        for photo in photos{
            imageCache.append(photo.imgData as! Data)
        }
    }
    
    func removePhotos(){
        for photo in photos{
            stack.context.delete(photo)
        }
        photos = []
    }
    
    
    func getFlickrPhotosFromLocation(coordinate: CLLocationCoordinate2D){
        FlickrClient.getFlickrPhotos(latitude: String(coordinate.latitude), longitude: String(coordinate.longitude)) { (error, photoArray) in
            if(error == nil){
                if (photoArray?.isEmpty)!{
                    self.getFlickrPhotosFromLocation(coordinate: coordinate)
                    return
                }
                else{
                    for photo in photoArray!{
                        print (photo.photoUrl.absoluteString)
                        DispatchQueue.main.async {
                            let photo = Photo(url: photo.photoUrl.absoluteString, context: self.stack.context)
                            photo.pin = self.pin
                            photo.imgData = nil
                            self.photos.append(photo)
                        }
                     
                    }
                    self.newCollectionButton.isEnabled = true
                    OperationQueue.main.addOperation {
                        self.collectionView.reloadData()
                    }
                }
            
            }
            else{
                self.displayAlert(error!, title: "")
            }
        }
        
    }
    
    
    func getPhotos(url: URL){
        
        FlickrClient.getDataFromUrl(url: url, completion: { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Problem downloading photo from \(url)")
                return
            }
                let photo = Photo(img: data as NSData, context: self.stack.context)
                photo.pin = self.pin
                self.photos.append(photo)
            
          
                OperationQueue.main.addOperation {
                    self.collectionView.reloadData()
                }
            
        })
        
    }
    
    func loadPhotos()
    {
        let pred = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fr.predicate = pred
        
        let fetchedResults = try? stack.context.fetch(fr)
        
        if let results = fetchedResults
        {
           photos = results as! [Photo]
        }else{
            print("error retrieving photos")
        }
        for photo in photos{
            imageCache.append(photo.imgData as! Data)
        }
        
        collectionView.reloadData()
    }
    
    
    func addAnnotation(){
            let annotation = MKPointAnnotation()
            let newCoordinate = CLLocationCoordinate2D(latitude: pin!.latitude, longitude: pin!.longitude)
            annotation.coordinate = newCoordinate
            annotation.title = pin?.locationName
        
            let span = MKCoordinateSpanMake(5, 5)
            let region = MKCoordinateRegion(center: newCoordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
    }
    

}


extension PhotoAlbumViewController: MKMapViewDelegate{
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


//     MARK: Flow Layout
    
extension PhotoAlbumViewController: UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
}



    // MARK: Collection View Data Source
extension PhotoAlbumViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = self.photos[(indexPath as NSIndexPath).row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pic", for: indexPath) as! PhotoCollectionViewCell
        
        if (photo.imgData != nil){
            cell.pic?.image =  UIImage(data: photo.imgData as! Data)
        }
        else{
            let url = URL(string:photo.url!)
            FlickrClient.getDataFromUrl(url: url!, completion: { (data, response, error) in
                
                guard let data = data, error == nil else {
                    print("Problem downloading photo from \(url)")
                    return
                }
                DispatchQueue.main.async {
                cell.pic?.image = UIImage(data: data)
                photo.imgData = data as NSData?
                //self.collectionView.reloadData()
                cell.actInd.stopAnimating()
                }
               
            })
            cell.pic?.image = UIImage(named: "default.png")
            cell.actInd.startAnimating()
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.stack.context.delete(self.photos[(indexPath as NSIndexPath).row])
        photos.remove(at: indexPath.item)
        collectionView.reloadData()
        
    }
    

    
}


extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            collectionView.insertSections(set)
        case .delete:
            collectionView.deleteSections(set)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.deleteItems(at: [indexPath!])
            collectionView.insertItems(at: [newIndexPath!])
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
