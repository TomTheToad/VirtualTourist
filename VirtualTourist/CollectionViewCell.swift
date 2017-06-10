//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var id: String?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                alpha = 0.5
            } else {
                alpha = 1.0
            }
        }
    }
    
    // IBOutlets
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
