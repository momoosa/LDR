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
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if let savedIdentifier = UserDefaults.standard.string(forKey: "SavedRecordID") {
            
            let identifier = CKRecord.ID(recordName: savedIdentifier)
            CloudKitService.shared.fetchRecord(identifier) { (record, error) in
                
            }
            setupLocalNotification { (error) in
                
            }
        }

        if let value = launchOptions?[.location] as? Bool, value == true {
            
        }
        
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        locationManager.stopMonitoringSignificantLocationChanges()
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
