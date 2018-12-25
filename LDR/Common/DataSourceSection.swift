//
//  DataSourceSection.swift
//  MooKit
//
//  Created by Mo Moosa on 25/12/2017.
//  Copyright © 2017 Mo Moosa. All rights reserved.
//

import Foundation

open class DataSourceSection: Hashable {
    
    public var identifier: String?
    public var sectionDate: Date?
    public var headerTitle: String?
    public var displayHeaderTitle: String? {
        
        if let headerTitle = self.headerTitle {
            
            if showItemsCount == true, self.items.count > 0 {
                
                return "\(headerTitle) (\(items.count))"
                
            } else {
                
                return headerTitle
            }
        }
        
        return nil
    }
    
    public var showItemsCount = false
    public var attributedFooterTitle: NSAttributedString?
    public var footerTitle: String?
    public var canShowEmptyView = false
    public var shouldAlwaysShowPlaceholderItem = false
    
    
    fileprivate var sectionItems = [Any]()
    
    open var items: [Any] {
        
        get {
            return self.sectionItems
        }
        
        set {
            self.sectionItems = newValue
        }
    }
    
    // TODO: Rename?
    public var isEditable = false
    public var emptyMessage: String?
    
    public convenience init (items: [Any]?) {
        
        self.init(headerTitle: nil, footerTitle: nil, items: items)
    }
    
    public convenience init (headerTitle: String?, items: [Any]?) {
        
        self.init(headerTitle: headerTitle, footerTitle: nil, items: items)
    }
    
    public init (headerTitle: String?, footerTitle: String?, items: [Any]?) {
        
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        
        self.items = items ?? self.items
    }
    
    public var hashValue: Int {
        
        guard let title = self.headerTitle else {
            
            return -1
        }
        
        return title.hashValue + items.count
    }
}


public func ==(lhs: DataSourceSection, rhs: DataSourceSection) -> Bool {
    
    return lhs.hashValue == rhs.hashValue
}
