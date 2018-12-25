//
//  TableViewCell.swift
//  LDR
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//


import UIKit

private let maximumImageHeight: CGFloat = 40.0

public protocol TableViewCellDelegate: class {
    
    func cellDidUpdate(_ cell: TableViewCell)
}

open class TableViewCell: UITableViewCell, DataSourceReusableView {
    var imageViewHeightConstraint: NSLayoutConstraint?
    public weak var delegate: TableViewCellDelegate?
    let titleStackView = UIStackView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    open override func awakeFromNib() {
        super.awakeFromNib()
    
        configureTitleStackView()
        configureTitleLabel()
        configureSubtitleLabel()
    }

    
    // MARK: Configuration
    
    private func configureTitleStackView() {
        
        titleStackView.axis = .vertical
        titleStackView.spacing = padding
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleStackView)
        
        titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        contentView.bottomAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: padding).isActive = true
        contentView.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor, constant: padding).isActive = true
    }
    
    private func configureTitleLabel() {
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.addArrangedSubview(titleLabel)
    }
    
    private func configureSubtitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.addArrangedSubview(subtitleLabel)
    }
    
    public func update(with model: CellViewModel) {
    
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        
        subtitleLabel.isHidden = model.subtitle == nil
    }
}
