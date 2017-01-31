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
class PhotoAlbumViewController :UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
   
    @IBOutlet var collectionView: UICollectionView!
    
    var photos: [Photo] = []
    var pin : Pin?

    
    
    // MARK: Properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView.reloadData()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        loadPhotos()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        collectionView.reloadData()
    }
    
    
    
    func loadPhotos()
    {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        let pred = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fr.predicate = pred
        
        let fetchedResults = try? stack.context.fetch(fr)
        
        if let results = fetchedResults
        {
           photos = results as! [Photo]
            print ("photos have been found! \(photos)")
        }else{
            print("error retrieving photos")
        }
        collectionView.reloadData()
    }
    
    
//    
//    func load_image(urlString:String)
//    {
//        
//        var imgURL: NSURL = NSURL(string: urlString)!
//        let request: NSURLRequest = NSURLRequest(URL: imgURL)
//        NSURLConnection.sendAsynchronousRequest(
//            request, queue: NSOperationQueue.mainQueue(),
//            completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//                if error == nil {
//                    self.TableData[index].image = UIImage(data: data)
//                    self.save(index,image: self.TableData[index].image!)
//                    
//                    imageview.image = self.TableData[index].image
//                    
//                }
//        })
//        
//    }
//    
//    
//     MARK: Flow Layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.photos.count)
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pic", for: indexPath) as! PhotoCollectionViewCell
        let photo = self.photos[(indexPath as NSIndexPath).row]
        print(photo)
        // Set the name and image
        // cell.nameLabel.text = meme.name
        cell.pic?.image =  UIImage(data: photo.imgData as! Data)
        return cell
    }
    
    
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
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
