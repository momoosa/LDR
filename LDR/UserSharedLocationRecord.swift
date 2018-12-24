//
//  UserSharedLocationRecord.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation

final class UserSharedLocationRecord: NSObject {
    @objc var identifier: String?
    @objc var firstUserIdentifier: String?
    @objc var secondUserIdentifier: String?
    @objc var firstUserLocationLatitude: Double = 0.0
    @objc var firstUserLocationLongitude: Double = 0.0
    @objc var secondUserLocationLatitude: Double = 0.0
    @objc var secondUserLocationLongitude: Double = 0.0
    var shouldSync: Bool = false
    var shouldDestroy: Bool = false
    var lastModifiedDate: Date? = Date()
    
    override init() {
        self.identifier = UUID().uuidString
    }
}

extension UserSharedLocationRecord: Syncable {
    func JSONRepresentation() -> [String : Any] {
        var dictionary = [String: Any]()
        
        dictionary[#keyPath(firstUserIdentifier)] = firstUserIdentifier
        dictionary[#keyPath(secondUserIdentifier)] = secondUserIdentifier
        dictionary[#keyPath(firstUserLocationLatitude)] = firstUserLocationLatitude
        dictionary[#keyPath(firstUserLocationLongitude)] = firstUserLocationLongitude
        dictionary[#keyPath(secondUserLocationLatitude)] = secondUserLocationLatitude
        dictionary[#keyPath(secondUserLocationLongitude)] = secondUserLocationLongitude
        
        return dictionary
    }
    
    var syncableID: String? {
        return identifier
    }
    
    static var syncCategory: String {
        return "UserSharedLocationRecords"
    }
    
    static var remotePrimaryKey: String {
        return #keyPath(identifier)
    }
}
