//
//  AppDelegate.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/27/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import UIKit
import CoreData

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Virtual_tourist")!
    
    // MARK: Preload Data
    
        
    // MARK: Background Load
    
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Start Autosaving
        stack.autoSave(10)
        // add new objects in the background
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(5 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
//            self.backgroundLoad()
//        }
        return true
    
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        stack.save()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
    }
}
