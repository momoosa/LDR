//
//  CKContainerApplicationPermissionStatus+Extensions.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import CloudKit

extension CKContainer_Application_PermissionStatus {
    
    var localizedStatus: String {
        
        switch self {
        case .granted:
            return NSLocalizedString("iCloud account visibility enabled 😎", comment: "")
            
        case .initialState:
            return NSLocalizedString("iCloud account visibility needs to be enabled.", comment: "")
            
        case .couldNotComplete:
            return NSLocalizedString("iCloud account visibility restricted.", comment: "")
            
        case .denied:
            return NSLocalizedString("iCloud account visibility restricted 🚫", comment: "")
            
        default:
            return ""
        }
    }
}
