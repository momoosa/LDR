//
//  UserSharedLocationRecord.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import CoreLocation

final class UserSharedLocationRecord: NSObject {
    @objc var identifier: String?
    @objc var firstUserIdentifier: String?
    @objc var secondUserIdentifier: String?
    @objc var firstUserLocation: CLLocation?
    @objc var secondUserLocation: CLLocation?
    @objc var firstUserLocationModifiedDate: Date?
    @objc var secondUserLocationModifiedDate: Date?

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
        
        dictionary[#keyPath(firstUserLocation)] = firstUserLocation
        dictionary[#keyPath(secondUserLocation)] = secondUserLocation
        dictionary[#keyPath(firstUserIdentifier)] = firstUserIdentifier
        dictionary[#keyPath(secondUserIdentifier)] = secondUserIdentifier
        
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
