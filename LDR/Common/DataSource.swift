//
//  DataSource.swift
//  DowntimeKit
//
//  Created by Mo Moosa on 25/12/2018.
//  Copyright © 2018 Mo Moosa. All rights reserved.
//

import UIKit


public protocol DataSourceReusableView {
    func update(with model: CellViewModel)
}

public typealias DataSourceCellIdentifierBlock = (Any) -> String?
public typealias DataSourceViewConfigurationBlock = (DataSourceReusableView?, Any?, IndexPath) -> Void

public protocol DataSourceView {
    
    func dequeueReusableView(with reuseIdentifier: String, for indexPath: IndexPath) -> DataSourceReusableView?
}


open class DataSource: NSObject {
    public var sections = [DataSourceSection]()
    public var cellIdentifier = "defaultDataSourceCellIdentifier"
    public var cellReuseIdentifierBlock: DataSourceCellIdentifierBlock?
    public var cellConfigurationBlock: DataSourceViewConfigurationBlock?
    public var isEmpty: Bool {
        
        for section in sections {
            
            if section.items.isEmpty == false {
                
                return false
            }
        }
        
        return true
    }
    
    open func reusableView<T>(for view: T, at indexPath: IndexPath) -> DataSourceReusableView? where T: DataSourceView {
        
        var cell: DataSourceReusableView?
        let dataSourceItem = item(at: indexPath)
        var identifier = cellIdentifier
        
        if let dataSourceItem = dataSourceItem, let itemIdentifier = cellReuseIdentifierBlock?(dataSourceItem) {
            identifier = itemIdentifier
        }
        
        cell = view.dequeueReusableView(with: identifier, for: indexPath)
        
        if let configurationBlock = cellConfigurationBlock {
            
            configurationBlock(cell, dataSourceItem, indexPath)
            
        } else if let cell = cell, let viewModel = dataSourceItem as? CellViewModel {
            
            cell.update(with: viewModel)
        }
        
        return cell!
    }
    
    public func numberOfSections(in dataSourceView: DataSourceView) -> Int {
        
        return sections.count
    }
    
    public func numberOfItems(in dataSourceViewSection: Int) -> Int {
                
        return sections[dataSourceViewSection].items.count
    }
    
    public func item(at indexPath: IndexPath) -> Any? {
        
        let findItem: ([DataSourceSection]) -> Any? = { sections in
            
            guard indexPath.section < sections.count else {
                return nil
            }
            
            let section = sections[indexPath.section]
            
            guard indexPath.item < section.items.count && indexPath.row < section.items.count else {
                return nil
            }
            
            return section.items[indexPath.item]
        }
        
        return findItem(sections)
    }
    
    public func indexPath(forItem item: NSObject) -> IndexPath? {
        
        for section in sections {
            
            guard let items = section.items as? [NSObject] else {
                
                continue
            }
            
            for existingItem in items {
                
                if existingItem == item {
                    
                    if let index = items.index(of: existingItem), let sectionIndex = sections.index(of: section) {
                        
                        return IndexPath(row: index, section: sectionIndex)
                    }
                }
            }
        }
        return nil
    }
    
}

extension UITableView: DataSourceView {
    
    public func dequeueReusableView(with reuseIdentifier: String, for indexPath: IndexPath) -> DataSourceReusableView? {
        guard let view = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DataSourceReusableView else {
            return nil
        }
        
        return view
    }
}

extension UICollectionView: DataSourceView {
    
    public func dequeueReusableView(with reuseIdentifier: String, for indexPath: IndexPath) -> DataSourceReusableView? {
        guard let view = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DataSourceReusableView else {
            return nil
        }
        
        return view
    }
}
