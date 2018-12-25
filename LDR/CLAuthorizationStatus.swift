//
//  CLAuthorizationStatus.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import CoreLocation

extension CLAuthorizationStatus {
    
    var localizedStatus: String {
        
        switch self {
        case .authorizedAlways:
            return NSLocalizedString("Authorized (including background use)", comment: "")
            
        case .authorizedWhenInUse:
            return NSLocalizedString("Authorized (only when in use; functionality may be limited.)", comment: "")
            
        case .denied:
            return NSLocalizedString("Authorization denied, please change in Settings", comment: "")
            
        case .notDetermined:
            return NSLocalizedString("Not determined", comment: "")
            
        case .restricted:
            return  NSLocalizedString("Authorization restricted", comment: "")
        }
    }
}
