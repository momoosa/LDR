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
    
    func usersAreNearEachOther() -> Bool {
        
        guard let firstLocation = firstUserLocation, let secondLocation = secondUserLocation else {
            return false
        }
        
        guard let firstDate = firstUserLocationModifiedDate, let secondDate = secondUserLocationModifiedDate else {
            return false
        }

        // TODO: Check modified dates?
        return firstLocation.distance(from: secondLocation) < 50
        
    }
}

extension UserSharedLocationRecord: Syncable {
    func JSONRepresentation() -> [String : Any] {
        var dictionary = [String: Any]()
        
        dictionary[#keyPath(identifier)] = identifier
        dictionary[#keyPath(firstUserLocation)] = firstUserLocation
        dictionary[#keyPath(secondUserLocation)] = secondUserLocation
        dictionary[#keyPath(firstUserIdentifier)] = firstUserIdentifier
        dictionary[#keyPath(secondUserIdentifier)] = secondUserIdentifier
        dictionary[#keyPath(firstUserLocationModifiedDate)] = firstUserLocationModifiedDate
        dictionary[#keyPath(secondUserLocationModifiedDate)] = secondUserLocationModifiedDate

        
        return dictionary
    }
    
    func updateFromDictionary(_ dictionary: [AnyHashable : Any]) {
        
        identifier = dictionary[#keyPath(identifier)] as? String ?? identifier
        
        firstUserLocation = dictionary[#keyPath(firstUserLocation)] as? CLLocation
        firstUserIdentifier = dictionary[#keyPath(firstUserIdentifier)] as? String
        firstUserLocationModifiedDate = dictionary[#keyPath(firstUserLocationModifiedDate)] as? Date

        secondUserIdentifier = dictionary[#keyPath(secondUserIdentifier)] as? String
        secondUserLocation = dictionary[#keyPath(secondUserLocation)] as? CLLocation
        secondUserLocationModifiedDate = dictionary[#keyPath(secondUserLocationModifiedDate)] as? Date
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
