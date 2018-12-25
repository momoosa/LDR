//
//  ViewController.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

final class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private let dataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureLocationManager()
        configureSignificationLocationsUpdating()
        configureRegisterNotificationsButton()
        configureTableViewDataSource()
        configureItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCloudKitStatusLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: NSNotification.Name.CKAccountChanged, object: nil)
        
        CloudKitService.shared.fetchRecords(ofType: UserSharedLocationRecord.self) { (results, error) in
            if let error = error {
                print("Error fetching CloudKit Records: \(error)")
            }
            
            if let results = results as? [Any] {
                
                if results.isEmpty == true {
                    
                    let newRecord = UserSharedLocationRecord()
                    newRecord.firstUserLocationLongitude = self.location?.coordinate.longitude ?? 0.0
                    newRecord.firstUserLocationLatitude = self.location?.coordinate.latitude ?? 0.0
                    
                    CloudKitService.shared.sync(withCloudKitRecordType: UserSharedLocationRecord.self, syncables: [newRecord], completion: { ([[AnyHashable : Any]]?, error) in
                        
                    })
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureRegisterNotificationsButton() {
        
        let center =  UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                break
//                self.registerNotificationsButton.setTitle(NSLocalizedString("Registered for Notifications ✅", comment: ""), for: .disabled)
//                self.registerNotificationsButton.isEnabled = false
            case .denied, .notDetermined:
                break
//                self.registerNotificationsButton.isSpringLoaded = true
//                self.registerNotificationsButton.isEnabled = true
            }
        }
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    private func configureSignificationLocationsUpdating() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() == true else {
            print("CLLocationManager Error: Significant Locations Service is unavailable.")
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func configureTableViewDataSource() {
        tableView.dataSource = dataSource
        
        dataSource.cellReuseIdentifierBlock = { item in
            
            return "PermissionTableViewCell"
        }
    }
    
    private func configureItems() {
        
        let cloudKitPermissionItem = PermissionItem.init(identifier: "cloudKit", title: NSLocalizedString("iCloud Account", comment: ""), status: nil, action: nil)

        let notificationPermissionItem = PermissionItem.init(identifier: "cloudKit", title: NSLocalizedString("Notifications", comment: ""), status: nil, action: nil)
        
        let viewModels = [cloudKitPermissionItem, notificationPermissionItem].map({ PermissionCellViewModel(permissionItem: $0) })
        let dataSourceSection = DataSourceSection(items: viewModels)
        
        dataSource.sections = [dataSourceSection]

    }
    // MARK: - Content
    
    private func updateCloudKitStatusLabel() {
        CloudKitService.shared.requestCloudKitAccountStatus { (status, error) in
//            self.cloudKitStatusLabel.text = status.localizedStatus
        }
    }
    // MARK: - Notifications
    
    @objc func handleNotification(notification: Notification) {
        
        switch notification.name {
        case .CKAccountChanged:
            updateCloudKitStatusLabel()
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleRegisterNotificationsButtonTap(_ sender: Any) {
        
        let center =  UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
            self.configureRegisterNotificationsButton()
        }
    }
    
    @IBAction func handleUserDiscoverabilityButtonTap(_ sender: Any) {
        CloudKitService.shared.requestUserDiscoverabilityAccess { (status, error) in
            
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLocation = locations.first {
            location = newLocation
            
            CloudKitService.shared.fetchRecords(ofType: UserSharedLocationRecord.self) { (results, error) in
                if let error = error {
                    print("Error fetching CloudKit Records: \(error)")
                }
                
                if let results = results as? [Any] {
                    
                    if results.isEmpty == true {
                        
                        let newRecord = UserSharedLocationRecord()
                        newRecord.firstUserLocationLongitude = self.location?.coordinate.longitude ?? 0.0
                        newRecord.firstUserLocationLatitude = self.location?.coordinate.latitude ?? 0.0
                        
                        CloudKitService.shared.sync(withCloudKitRecordType: UserSharedLocationRecord.self, syncables: [newRecord], completion: { ([[AnyHashable : Any]]?, error) in
                            
                        })
                    }
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
