//
//  PermissionTableViewCell.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UIKit

final class PermissionCellViewModel: CellViewModel {
    var identifier: String
    var action: Action?
    var actionTitle: String?
    var image: UIImage?
    var subtitle: String?
    var description: String?
    var title: String?
    var isEnabled = false
    
    init(permissionItem: PermissionItem) {
        
        self.identifier = permissionItem.identifier
        self.title = permissionItem.title
        self.actionTitle = permissionItem.actionTitle
        self.subtitle = permissionItem.status
        self.action = permissionItem.action
        self.isEnabled = permissionItem.isEnabled
        self.description = permissionItem.description
    }
}

final class PermissionTableViewCell: TableViewCell {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var permissionTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    private var action: Action?
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12.5
        indicatorView.backgroundColor = UIColor.green
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        indicatorView.layer.cornerRadius = indicatorView.frame.size.height * 0.5
    }
    
    // MARK: - Content
    override func update(with model: CellViewModel) {
        
        if let model = model as? PermissionCellViewModel {
            permissionTitleLabel.text = model.title
            statusLabel.text = model.subtitle
            descriptionLabel.text = model.description
            action = model.action
            button.setTitle(model.actionTitle, for: [])
            var newAlpha: CGFloat = 1.0
            
            if model.isEnabled == true {
                isUserInteractionEnabled = true
            } else {
                newAlpha = 0.25
                isUserInteractionEnabled = false
            }
            
            if newAlpha != contentView.alpha {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.alpha = newAlpha
                }
            }
        }
    }
    @IBAction func handleButtonTap(_ sender: Any) {
        action?()
    }
}
