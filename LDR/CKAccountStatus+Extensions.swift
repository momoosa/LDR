//
//  CKAccountStatus+Extensions.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation
import CloudKit

extension CKAccountStatus {

    var localizedStatus: String {
        
        switch self {
        case .available:
            return NSLocalizedString("iCloud account configured 😎", comment: "")

        case .couldNotDetermine:
            return NSLocalizedString("iCloud account status could not be determined 🕵️‍♂️", comment: "")

        case .noAccount:
            return NSLocalizedString("No iCloud account detected ☹️ \nSign into an account via Settings > iCloud.", comment: "")

        case .restricted:
            return NSLocalizedString("iCloud account access restricted 🚫", comment: "")

            
        default:
            return ""
        }
    }
    
    var permissionItemStatus: PermissionItemStatus {
        
        switch self {
        case .available:
            return .optimal
        case .noAccount, .restricted:
            return .needsAssistance
        case .couldNotDetermine:
            return .uncertain
        }
    }

}
