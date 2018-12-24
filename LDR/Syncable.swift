//
//  Syncable.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation
import CloudKit

@objc public protocol Syncable {
    
    func JSONRepresentation() -> [String: Any]
    @objc optional func updateFromDictionary(_ dictionary: [AnyHashable: Any])
    @objc optional func updateFromRecord(_ record: CKRecord)
    
    var syncableID: String? { get }
    var shouldSync: Bool { get set }
    var shouldDestroy: Bool { get set }
    var lastModifiedDate: Date? { get set }
    static var syncCategory: String { get }
    static var remotePrimaryKey: String { get }
}

public protocol MediaSyncable: Syncable {
    
    var mediaDataRemoteKey: String? { get }
    var mediaData: Data? { get set }
}
