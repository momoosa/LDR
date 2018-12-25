//
//  PermissionTableViewCell.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UIKit

final class PermissionCellViewModel: CellViewModel {
    var action: Action?
    var image: UIImage?
    var subtitle: String?
    var title: String?
    
    init(permissionItem: PermissionItem) {
        
        self.title = permissionItem.title
        self.subtitle = permissionItem.status
        self.action = permissionItem.action
    }
}

final class PermissionTableViewCell: TableViewCell {
    
    @IBOutlet weak var permissionTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    private var action: Action?
    
    override func update(with model: CellViewModel) {
        
        if let model = model as? PermissionCellViewModel {
            permissionTitleLabel.text = model.title
            statusLabel.text = model.subtitle
            action = model.action
        }
    }
    @IBAction func handleButtonTap(_ sender: Any) {
        action?()
    }
}
