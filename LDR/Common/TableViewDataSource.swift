//
//  TableViewDataSource.swift
//  NutriKit
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import UIKit
import CoreData

public typealias ConfigurationBlock = (UITableViewCell, Any) -> Void
public typealias CellIdentifierBlock = (Any) -> String?

public class TableViewDataSource: DataSource {
    public weak var tableView: UITableView?
    public var canEditRows = false
}

extension TableViewDataSource: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.reusableView(for: tableView, at: indexPath) as! UITableViewCell
    }
    //
    //    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //
    //        guard let collectionSection = self.items?[section] else {
    //
    //            return nil
    //        }
    //
    //        return collectionSection.footerTitle
    //    }
    //
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditRows && sections[indexPath.section].isEditable
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var itemsToEdit: [CellViewModel]?
        
        if let items = sections[indexPath.section].items as? [CellViewModel] {
            itemsToEdit = items
        }
        
        guard itemsToEdit != nil else {
            
            return
        }
        
        guard let item = itemsToEdit?[indexPath.row] else {
            
            return
        }
        
        switch editingStyle {
            
        case .delete:
            
            
            guard let index = itemsToEdit?.index(where: { (syncable) -> Bool in
                
                // TODO: Fix when CellViewModel supports equatable
                
                if let syncableObject = syncable as? NSObject, let itemObject = item as? NSObject, syncableObject == itemObject {
                    
                    return true
                    
                }
                return false
            }) else {
                
                return
            }
            
            
            itemsToEdit?.remove(at: index)
            
            // TODO: Improve once CellViewModel is class protocol
                if let itemsToEdit = itemsToEdit {
                    
                    sections[indexPath.section].items = itemsToEdit
                }
            
            
        default:
            break
        }
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //        model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
}
