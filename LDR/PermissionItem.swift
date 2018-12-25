//
//  PermissionItem.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation

struct PermissionItem {
    var identifier: String
    var title: String?
    var status: String?
    var description: String?
    var actionTitle: String?
    var isEnabled = false
    var action: Action?
}

extension PermissionItem: Equatable {
    static func == (lhs: PermissionItem, rhs: PermissionItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
