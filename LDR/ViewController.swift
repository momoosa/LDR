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
    private let dataSource = TableViewDataSource()
    private var items = [PermissionItem]()
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        configureSignificationLocationsUpdating()
        configureTableViewDataSource()
        configureItems()
        configureRegisterNotificationsButton()
        updateCloudKitVisibilityStatusUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCloudKitStatusUI()
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureRegisterNotificationsButton() {
        
        let center =  UNUserNotificationCenter.current()
        center.getNotificationSettings { [unowned self] (settings) in
            
            DispatchQueue.main.async {
                guard let notificationItem = self.items.first(where: { $0.identifier == "notificationItem"}), let index = self.items.index(of: notificationItem) else {
                    return
                }
                
                if settings.authorizationStatus == UNAuthorizationStatus.notDetermined {
                    notificationItem.actionTitle = NSLocalizedString("Request Notifications Access", comment: "")
                    notificationItem.action = {
                        self.updateNotificationAccess()
                    }
                } else {
                    notificationItem.actionTitle = nil
                    notificationItem.action = nil
                }
                
                notificationItem.statusText = settings.authorizationStatus.localizedStatus
                notificationItem.status = settings.authorizationStatus.permissionItemStatus
                self.items[index] = notificationItem
                self.updateTableView()
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
            
            self.updateCloudKitStatusUI()
        })
        cloudKitPermissionItem.description = NSLocalizedString("Your iCloud account is used to sync data between you and your friend.", comment: "")
        
        let cloudKitVisibilityPermissionItem = PermissionItem.init(identifier: "cloudKitVisibilityItem", title: NSLocalizedString("iCloud Account Visibility", comment: ""), statusText: nil, isEnabled: false, action: {
            
            self.updateCloudKitVisibilityStatusUI()
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
        updateTableView()
    }
    // MARK: - Content
    
    private func updateTableView() {
        
        let viewModels = items.map({ PermissionCellViewModel(permissionItem: $0) })
        let dataSourceSection = DataSourceSection(items: viewModels)
        
        dataSource.sections = [dataSourceSection]
        tableView.reloadData()
    }
    
    private func updateCloudKitStatusUI() {
        
        CloudKitService.shared.requestCloudKitAccountStatus { (status, error) in
            
            if let cloudKitItem = self.items.first(where: { $0.identifier == "cloudKitItem" }), let index = self.items.index(of: cloudKitItem) {
                
                cloudKitItem.status = status.permissionItemStatus
                cloudKitItem.statusText = status.localizedStatus
                self.items[index] = cloudKitItem
                
                if status == CKAccountStatus.available {
                    
                    if let visibilityItem = self.items.first(where: { $0.identifier == "cloudKitVisibilityItem"}), let index = self.items.index(of: visibilityItem) {
                        
                        visibilityItem.isEnabled = true
                        visibilityItem.actionTitle = NSLocalizedString("Request User Discoverability", comment: "")
                        visibilityItem.action = {
                            
                            self.requestUserDiscoverabilityAccess()
                        }
                        
                        self.items[index] = visibilityItem
                    }
                    cloudKitItem.actionTitle = nil
                } else {
                    cloudKitItem.actionTitle = nil
                }
                self.updateTableView()
            }
        }
    }
    
    private func updateCloudKitVisibilityStatusUI() {
        
        CloudKitService.shared.requestCloudKitUserVisibilityStatus { [unowned self] (status, error) in
            
            if let cloudKitItem = self.items.first(where: { $0.identifier == "cloudKitVisibilityItem" }), let index = self.items.index(of: cloudKitItem) {
                
                if status == .granted {
                    cloudKitItem.actionTitle = nil
                }
                // TODO: Check Equatable
                cloudKitItem.statusText = status.localizedStatus
                cloudKitItem.status = status.permissionItemStatus
                self.items[index] = cloudKitItem
                self.updateTableView()
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
            updateCloudKitStatusUI()
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    func updateNotificationAccess() {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (result, error) in
            DispatchQueue.main.async {
                self.configureRegisterNotificationsButton()
            }
        }
    }
    
    private func requestUserDiscoverabilityAccess() {
        
        CloudKitService.shared.requestUserDiscoverabilityAccess { [unowned self] (status, error) in
            
            guard let visibilityItem = self.items.first(where: { $0.identifier == "cloudKitVisibilityItem"}), let index = self.items.index(of: visibilityItem) else {
                return
            }
            
            visibilityItem.status = status?.permissionItemStatus ?? visibilityItem.status
            visibilityItem.isEnabled = true
            visibilityItem.statusText = status?.localizedStatus
            visibilityItem.actionTitle = NSLocalizedString("Request User Discoverability", comment: "")
            self.items[index] = visibilityItem
            self.updateTableView()
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
        
        guard let locationItem = self.items.first(where: { $0.identifier == "locationItem"}), let index = self.items.index(of: locationItem) else {
            return
        }
        
        locationItem.status = status.permissionItemStatus
        locationItem.isEnabled = true
        locationItem.statusText = status.localizedStatus
        self.items[index] = locationItem
        self.updateTableView()
        
    }
}
