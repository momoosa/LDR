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
import CloudKit

final class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private let dataSource = TableViewDataSource()
    private var items = [PermissionItem]()
    
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
        
        let cloudKitDescription = NSLocalizedString("Your iCloud account is used to sync data between you and your friend.", comment: "")
        let cloudKitPermissionItem = PermissionItem.init(identifier: "cloudKitItem", title: NSLocalizedString("iCloud Account", comment: ""), status: nil, description: cloudKitDescription, actionTitle: nil, isEnabled: true, action: {
            
            self.updateCloudKitStatusLabel()
        })

        let cloudKitVisibilityDescription = NSLocalizedString("Your account visibility needs to be enabled so that friends can look up your account.", comment: "")

        let cloudKitVisibilityPermissionItem = PermissionItem.init(identifier: "cloudKitVisibilityItem", title: NSLocalizedString("iCloud Account Visibility", comment: ""), status: nil, description: cloudKitVisibilityDescription, actionTitle: nil, isEnabled: false, action: {
            
            self.updateCloudKitVisibilityStatusLabel()
        })

        let locationDescription = NSLocalizedString("Your location is used to determine when you're close to your friend.", comment: "")

        let locationPermissionItem = PermissionItem.init(identifier: "locationItem", title: NSLocalizedString("Your Location", comment: ""), status: CLLocationManager.authorizationStatus().localizedStatus, description: locationDescription, actionTitle: nil, isEnabled: true, action: {
            
            self.updateLocationStatus()
        })
        
        let notificationDescription = NSLocalizedString("Enabling notifications will allow the app to notify you of your list when you're near your friend.", comment: "")

        let notificationPermissionItem = PermissionItem.init(identifier: "notificationItem", title: NSLocalizedString("Notifications", comment: ""), status: nil, description: notificationDescription, actionTitle: nil, isEnabled: true, action: nil)
        
        items = [cloudKitPermissionItem, cloudKitVisibilityPermissionItem, locationPermissionItem, notificationPermissionItem]
        let viewModels = items.map({ PermissionCellViewModel(permissionItem: $0) })
        let dataSourceSection = DataSourceSection(items: viewModels)
        
        dataSource.sections = [dataSourceSection]

    }
    // MARK: - Content
    
    private func updateCloudKitStatusLabel() {
        CloudKitService.shared.requestCloudKitAccountStatus { (status, error) in
            
            if var cloudKitItem = self.items.first(where: { $0.identifier == "cloudKitItem" }) {
                
                // TODO: Check Equatable
                cloudKitItem.status = status.localizedStatus
                self.items[0] = cloudKitItem
                
                if status == CKAccountStatus.available {
                    self.items[1].isEnabled = true
                    self.items[1].actionTitle = NSLocalizedString("Request User Discoverability", comment: "")
                    self.items[1].action = {
                        
                        self.requestUserDiscoverabilityAccess()
                    }
                    cloudKitItem.actionTitle = NSLocalizedString("", comment: "")
                }
                let viewModels = self.items.map({ PermissionCellViewModel(permissionItem: $0) })
                let dataSourceSection = DataSourceSection(items: viewModels)
                
                self.dataSource.sections = [dataSourceSection]

                self.tableView.reloadData()
            }
        }
    }
    
    private func updateCloudKitVisibilityStatusLabel() {
        
        CloudKitService.shared.requestCloudKitUserVisibilityStatus { (status, error) in
            
            if var cloudKitItem = self.items.first(where: { $0.identifier == "cloudKitVisibilityItem" }) {
                
                // TODO: Check Equatable
                cloudKitItem.status = status.localizedStatus
                self.items[1] = cloudKitItem
                
                let viewModels = self.items.map({ PermissionCellViewModel(permissionItem: $0) })
                let dataSourceSection = DataSourceSection(items: viewModels)
                
                self.dataSource.sections = [dataSourceSection]
                
                self.tableView.reloadData()
            
        }
    }
    }
    
    private func updateLocationStatus() {
        
        locationManager.requestAlwaysAuthorization()
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
    
    private func requestUserDiscoverabilityAccess() {
        CloudKitService.shared.requestUserDiscoverabilityAccess { (status, error) in
            
            self.items[1].isEnabled = true
            self.items[1].status = status?.localizedStatus
            self.items[1].actionTitle = NSLocalizedString("Request User Discoverability", comment: "")
            
            let viewModels = self.items.map({ PermissionCellViewModel(permissionItem: $0) })
            let dataSourceSection = DataSourceSection(items: viewModels)
            
            self.dataSource.sections = [dataSourceSection]

            self.tableView.reloadData()
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
