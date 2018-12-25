//
//  UNAuthorizationStatus+Extensions.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UserNotifications

extension UNAuthorizationStatus {
    
    var localizedStatus: String {
        
        switch self {
        case .authorized, .provisional:
            return NSLocalizedString("Notifications enabled 😎", comment: "")
        
        case .notDetermined:
            return NSLocalizedString("Notifications access is not yet determined.", comment: "")

        case .denied:
            return NSLocalizedString("Notifications access is disabled - please check Settings.", comment: "")
        }
    }
    
    var permissionItemStatus: PermissionItemStatus {
        
        switch self {
        case .authorized, .provisional:
            return .optimal
        case .denied:
            return .needsAssistance
        case .notDetermined:
            return .uncertain
        }
    }

}
