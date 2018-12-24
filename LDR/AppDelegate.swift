//
//  AppDelegate.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if let value = launchOptions?[.location] as? Bool, value == true {
            
            setupLocalNotification { (error) in
                
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

extension AppDelegate {
    
    fileprivate func setupLocalNotification(completion: @escaping (Error?) -> ()) {
        let center =  UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("You're nearby 😱", comment: "")
        content.body = "LDR has four activities to remind you about."
        
        // TODO: Add location trigger perhaps?
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2.0, repeats: false)
        
        // TODO: Update content identifier
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error displaying notification: \(error)")
            }
            completion(error)
        }
    }
}
