//
//  PermissionItem.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation
enum PermissionItemStatus {
    case optimal,
    uncertain,
    needsAssistance
}

final class PermissionItem {
    var status = PermissionItemStatus.uncertain
    var identifier: String = ""
    var title: String?
    var statusText: String?
    var description: String?
    var actionTitle: String?
    var isEnabled = false
    var action: Action?
    
    init(identifier: String, title: String?, statusText: String?, isEnabled: Bool, action: Action?) {
        self.identifier = identifier
        self.title = title
        self.statusText = statusText
        self.isEnabled = isEnabled
        self.action = action
    }
}

extension PermissionItem: Equatable {
    static func == (lhs: PermissionItem, rhs: PermissionItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
