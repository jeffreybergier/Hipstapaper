//
//  URLItemCollectionViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class URLItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel?
    
    var id: String?
    var urlItem: URLItemType? {
        didSet {
            if let id = self.id, let item = self.urlItem, item.realmID == id || item.cloudKitID == id {
                self.label?.text = item.urlString
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.id = .none
        self.urlItem = .none
    }
}
