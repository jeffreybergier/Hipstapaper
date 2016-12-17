//
//  URLItemTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

//import HipstapaperPersistence
import UIKit

class URLItemTableViewCell: UITableViewCell {
    
    static let nibName = "URLItemTableViewCell"

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet private weak var urlLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var idLabel: UILabel?
    
    var item: URLItem? {
        didSet {
            if let item = item {
                self.urlLabel?.text = item.urlString
                self.dateLabel?.text = self.dateFormatter.string(from: item.modificationDate)
                self.idLabel?.text = item.uuid
            } else {
                self.prepareForReuse()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.urlLabel?.text = .none
        self.dateLabel?.text = .none
        self.idLabel?.text = .none
    }
    
}
