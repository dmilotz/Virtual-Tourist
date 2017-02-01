//
//  FlickrClient.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//



import Foundation
import UIKit
// MARK: - OnTheMapClient: NSObject

class FlickrClient : NSObject {
    
    // shared session
    var session = URLSession.shared

    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    
   static func getFlickrPhotos(latitude: String, longitude:String, completionHandlerForGetPhotos: @escaping (NSError?, [PhotoModel]?) -> Void) {
        
        
        let url = Constants.flickrApiUrl + Constants.flickrPhotoLocationMethod + FlickrArgs.apiKey +  FlickrArgs.latitude + latitude + FlickrArgs.longitude + longitude + FlickrArgs.jsonFormat
        
        print(url)
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
    
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(error)")
                completionHandlerForGetPhotos(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == 100 {
                        print(error?.localizedDescription)
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        completionHandlerForGetPhotos(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
                guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
                
                let flickrPhotos: [PhotoModel] = photosArray.map { photoDictionary in
                    
                    let photoId = photoDictionary["id"] as? String ?? ""
                    let farm = photoDictionary["farm"] as? Int ?? 0
                    let secret = photoDictionary["secret"] as? String ?? ""
                    let server = photoDictionary["server"] as? String ?? ""
                    let title = photoDictionary["title"] as? String ?? ""
                    
                    let flickrPhoto = PhotoModel(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                    return flickrPhoto
                }
                //print (flickrPhotos)
                completionHandlerForGetPhotos(nil, flickrPhotos)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                completionHandlerForGetPhotos(error, nil)
                return
            }
            
        })
        task.resume()

        
    }
    
    
   static func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data, error == nil else{
                print("problem loading photo from url \(url)")
                return
            }
            
            completion(data, response, error)
            }.resume()
    }


    
    
//    class func sharedInstance() -> FlickrClient {
//        struct Singleton {
//            static var sharedInstance = FlickrClient()
//        }
//        return Singleton.sharedInstance
//    }
}
