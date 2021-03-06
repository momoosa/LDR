//
//  CloudKitService.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation
import CloudKit

public typealias CloudKitServiceCKRecordCompletion = (CKRecord?, Error?) -> ()
public typealias CloudKitServiceDictionariesCompletion = ([[AnyHashable: Any]]?, Error?) -> ()
public typealias CloudKitServiceCompletion = (Any?, Error?) -> ()

enum CloudKitServiceError: Error {
    case missingRecord
}


final class CloudKitService {
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    static let shared = CloudKitService()
    private let container = CKContainer.default()
    private let privateDatabase = CKContainer(identifier: "iCloud.com.moosa.ios.LDR").privateCloudDatabase
    private let publicDatabase = CKContainer(identifier: "iCloud.com.moosa.ios.LDR").publicCloudDatabase

    
    init() {
        
        fetchUserID { (record, error) in
            
            self.setupCloudKitSubscriptions(forClasses: [UserSharedLocationRecord.self])
        }
    }

    func requestCloudKitAccountStatus(completion: ((CKAccountStatus, Error?) -> ())?) {

        container.accountStatus { [unowned self] (accountStatus, error) in

            if let error = error {
                print(error)
            }
            
            DispatchQueue.main.async {
                completion?(accountStatus, error)
            }
            
            self.accountStatus = accountStatus
        }
    }

    private func fetchUserID(completion: CloudKitServiceCKRecordCompletion?) {
        container.fetchUserRecordID(completionHandler: { (recordID, error) in
            
            if let error = error {
                
                debugPrint("Error fetching CloudKit user ID: \(error)")
                
            } else if let recordID = recordID {
                
                self.fetchRecord(recordID, completion: { (record, error) in
                    User.cloudKitIdentifier = recordID.recordName
                    
                    completion?(record, nil)
                })
            } else {
                completion?(nil, CloudKitServiceError.missingRecord)
            }
        })
        
    }
    
    func fetchRecord(_ recordID: CKRecord.ID, completion: CloudKitServiceCKRecordCompletion?) {
        
        publicDatabase.fetch(withRecordID: recordID,
                              completionHandler: ({record, error in
                                
                                if let error = error {
                                    
                                    completion?(nil, error)
                                    return
                                    
                                } else {
                                    
                                    completion?(record, error)
                                }
                                }
        ))
    }
    
    func setupCloudKitSubscriptions(forClasses classes: [AnyClass]) {
        
        let predicate = NSPredicate(value: true)
        
        var subscriptions = [CKQuerySubscription]()
        
        for classType in classes {
            
            let identifier = String(describing: classType)
            
            guard UserDefaults.standard.string(forKey: identifier) == nil else {
                
                continue
            }
            
            let subscription = CKQuerySubscription(recordType: identifier, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
            
            subscriptions.append(subscription)
            
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptions, subscriptionIDsToDelete: nil)
            
            operation.modifySubscriptionsCompletionBlock = { (savedSubscriptions, deletedSubscriptions, error) in
                
                if let savedSubscriptions = savedSubscriptions {
                    
                    for subscription in savedSubscriptions {
                        
                        if let subscription = subscription as? CKQuerySubscription {
                            
                            UserDefaults.standard.set(subscription.recordType, forKey: identifier)
                        }
                    }
                }
            }
            
            operation.qualityOfService = .utility
            
            publicDatabase.add(operation)
        }
    }
    
    func fetchRecords(ofType type: Syncable.Type, completion: CloudKitServiceCompletion?) {
        var remoteResults = [CKRecord]()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: String(describing: type), predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { record in
            
            remoteResults.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            
            if error != nil {
                
                completion?(nil, error)
                
                return
            }
            
            completion?(remoteResults, nil)
        }
        
        self.publicDatabase.add(operation)
    }

    
    func sync(withCloudKitRecordType type: Syncable.Type, syncables: [Syncable], completion: @escaping CloudKitServiceDictionariesCompletion) {
        
        var recordsToSave = [CKRecord]()
        
        fetchRecords(ofType: type) { (records, error) in
            
            // TODO: Check for existingRecord
            if error != nil {
                
                completion(nil, error)
                return
            }
            
            var recordsDictionary = [String: CKRecord]()
            
            if let records = records as? [CKRecord] {
                
                for record in records {
                    
                    recordsDictionary[record.recordID.recordName] = record
                }
            }
            
            
            for localObject in syncables {
                guard let syncableID = localObject.syncableID else {
                    return
                }
                let recordID = CKRecord.ID(recordName: syncableID)
                let recordType = String(describing: type)

                let record = CKRecord(recordType: recordType, recordID: recordID)
                
                record.update(withDictionary: localObject.JSONRepresentation())
                recordsToSave.append(record)
            }
            
                let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
                
                operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
                    
                    if let savedRecords = savedRecords {
                        
                        let dictionaries = savedRecords.map({ (record) -> [AnyHashable: Any] in
                            
                            return record.dictionaryWithValues(forKeys: record.allKeys())
                        })
                        completion(dictionaries, error)
                    } else {
                        
                        completion(nil, error)
                    }
                }
                
                self.publicDatabase.add(operation)
            }

        }
        
    }
