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
        configureTableViewDataSource()
        configureItems()
        configureRegisterNotificationsButton()
        updateCloudKitVisibilityStatusLabel()
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
                    newRecord.firstUserLocation = self.location
                    
                    CloudKitService.shared.sync(withCloudKitRecordType: UserSharedLocationRecord.self, syncables: [newRecord], completion: { (records, error) in
                        
                        UserDefaults.standard.set(records?.first!.recordID.recordName, forKey: "SavedRecordID")
                    })
                   
                }
            }
        }
    }
    
    // Fetch record with ID
    // Update with local data
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureRegisterNotificationsButton() {
        
        let center =  UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in

            DispatchQueue.main.async {
                
                if settings.authorizationStatus == UNAuthorizationStatus.notDetermined {
                    self.items[3].actionTitle = NSLocalizedString("Request Notifications Access", comment: "")
                    self.items[3].action = {
                        
                        self.requestNotificationsAccess()
                    }
                } else {
                    self.items[3].actionTitle = nil
                    self.items[3].action = nil
                }
                
                self.items[3].statusText = settings.authorizationStatus.localizedStatus
                self.items[3].status = settings.authorizationStatus.permissionItemStatus
                
                let viewModels = self.items.map({ PermissionCellViewModel(permissionItem: $0) })
                let dataSourceSection = DataSourceSection(items: viewModels)
                self.dataSource.sections = [dataSourceSection]
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
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
        
        let cloudKitPermissionItem = PermissionItem.init(identifier: "cloudKitItem", title: NSLocalizedString("iCloud Account", comment: ""), statusText: nil, isEnabled: true, action: {
            
            self.updateCloudKitStatusLabel()
        })
        cloudKitPermissionItem.description = NSLocalizedString("Your iCloud account is used to sync data between you and your friend.", comment: "")

        let cloudKitVisibilityPermissionItem = PermissionItem.init(identifier: "cloudKitVisibilityItem", title: NSLocalizedString("iCloud Account Visibility", comment: ""), statusText: nil, isEnabled: false, action: {
            
            self.updateCloudKitVisibilityStatusLabel()
        })
        
        cloudKitVisibilityPermissionItem.description = NSLocalizedString("Your account visibility needs to be enabled so that friends can look up your account.", comment: "")

        let locationPermissionItem = PermissionItem.init(identifier: "locationItem", title: NSLocalizedString("Your Location", comment: ""), statusText: CLLocationManager.authorizationStatus().localizedStatus, isEnabled: true, action: {
            
            self.updateLocationStatus()
        })
        locationPermissionItem.status = CLLocationManager.authorizationStatus().permissionItemStatus
        locationPermissionItem.description = NSLocalizedString("Your location is used to determine when you're close to your friend.", comment: "")
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationPermissionItem.actionTitle = NSLocalizedString("Request Location Access", comment: "")
            locationPermissionItem.action = {
                self.updateLocationStatus()
            }
        }
        
        let notificationPermissionItem = PermissionItem.init(identifier: "notificationItem", title: NSLocalizedString("Notifications", comment: ""), statusText: nil, isEnabled: true, action: nil)
        
        notificationPermissionItem.description = NSLocalizedString("Enabling notifications will allow the app to notify you of your list when you're near your friend.", comment: "")
        
        items = [cloudKitPermissionItem, cloudKitVisibilityPermissionItem, locationPermissionItem, notificationPermissionItem]
        let viewModels = items.map({ PermissionCellViewModel(permissionItem: $0) })
        let dataSourceSection = DataSourceSection(items: viewModels)
        
        dataSource.sections = [dataSourceSection]

    }
    // MARK: - Content
    
    private func updateCloudKitStatusLabel() {
        CloudKitService.shared.requestCloudKitAccountStatus { (status, error) in
            
            if var cloudKitItem = self.items.first(where: { $0.identifier == "cloudKitItem" }), let index = self.items.index(of: cloudKitItem) {
                
                // TODO: Check Equatable
                cloudKitItem.status = status.permissionItemStatus
                cloudKitItem.statusText = status.localizedStatus
                self.items[index] = cloudKitItem
                
                if status == CKAccountStatus.available {
                    
                    if var visibilityItem = self.items.first(where: { $0.identifier == "cloudKitVisibilityItem"}), let index = self.items.index(of: visibilityItem) {
                        
                        visibilityItem.isEnabled = true
                        visibilityItem.actionTitle = NSLocalizedString("Request User Discoverability", comment: "")
                        visibilityItem.action = {
                            
                            self.requestUserDiscoverabilityAccess()
                        }
                        
                        self.items[index] = visibilityItem
                    }
                    cloudKitItem.actionTitle = nil
                } else {
                    self.items[1].actionTitle = nil
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
                
                if status == .granted {
                    cloudKitItem.actionTitle = nil
                }
                // TODO: Check Equatable
                cloudKitItem.statusText = status.localizedStatus
                cloudKitItem.status = status.permissionItemStatus
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
    
    func requestNotificationsAccess() {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
            DispatchQueue.main.async {
                self.configureRegisterNotificationsButton()
            }
        }
    }
    
    private func requestUserDiscoverabilityAccess() {
        CloudKitService.shared.requestUserDiscoverabilityAccess { (status, error) in
            
            self.items[1].status = status?.permissionItemStatus ?? self.items[1].status
            self.items[1].isEnabled = true
            self.items[1].statusText = status?.localizedStatus
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
                        newRecord.firstUserLocation = self.location

                        CloudKitService.shared.sync(withCloudKitRecordType: UserSharedLocationRecord.self, syncables: [newRecord], completion: { results, error in
                            
                        })
                    }
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}
