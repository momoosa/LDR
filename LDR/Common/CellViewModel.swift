//
//  CellViewModel.swift
//  MooKit
//
//  Created by Mo Moosa on 25/12/2017.
//  Copyright © 2017 Mo Moosa. All rights reserved.
//

import UIKit

public protocol CellViewModel {
    var title: String? { get }
    var image: UIImage? { get }
    var subtitle: String? { get }
}
