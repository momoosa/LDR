//
//  CKRecord+Extensions.swift
//  LDR
//
//  Created by Mo Moosa on 23/12/2018.
//  Copyright © 2018 Mo Moosa Ltd. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    
    func dictionaryRepresentation() -> [AnyHashable: Any] {
        
        var dictionary = dictionaryWithValues(forKeys: allKeys())
        
        for key in dictionary.keys {
            
            if let value = dictionary[key] as? CKAsset {
                
                do {
                    let data = try Data(contentsOf: value.fileURL)
                    
                    dictionary[key] = data
                    
                } catch {
                    
                    print("could not convert CKAsset to data: \(error)")
                }
            }
        }
        
        return dictionary
    }
    func update(withDictionary dictionary: [AnyHashable: Any]) {
        
        for key in dictionary.keys {
            
            if let key = key as? String, let value = dictionary[key] as? NSObject {
                
                switch value {
                    
                case let value as NSString:
                    
                    self[key] = value
                    
                case let value as NSNumber:
                    
                    self[key] = value
                    
                case let value as NSArray:
                    
                    self[key] = value
                    
                case let value as NSDate:
                    
                    self[key] = value
                    
                case let value as NSData:
                    
                    self[key] = value
                    
                case let value as CKRecord.Reference:
                    
                    self[key] = value
                    
                case let value as CKAsset:
                    
                    self[key] = value
                    
                case let value as CLLocation:
                    
                    self[key] = value
                    
                default:
                    break
                }
            }
        }
    }
}

