//
//  URLItemCollectionViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/5/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit
import HipstapaperPersistence

class URLItemCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "URLItemCollectionViewCell"
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet private weak var urlLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var idLabel: UILabel?
    
    var id: String?
    var item: URLItemType? {
        didSet {
            if let item = self.item, let id = self.id, id == item.realmID || id == item.cloudKitID {
                self.urlLabel?.text = item.urlString
                self.dateLabel?.text = self.dateFormatter.string(from: item.modificationDate)
                self.idLabel?.text = item.cloudKitID
            } else {
                self.prepareForReuse()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.id = .none
        self.urlLabel?.text = .none
        self.dateLabel?.text = .none
        self.idLabel?.text = .none
    }

}
