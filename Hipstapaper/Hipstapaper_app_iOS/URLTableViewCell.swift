//
//  URLItemTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class URLTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 65
    static let nibName = "URLTableViewCell"
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var urlImageView: UIImageView?

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    func configure(with item: URLItem) {
        self.titleLabel?.text = item.title
        self.urlImageView?.image = item.image
        self.dateLabel?.text = self.dateFormatter.string(from: item.creationDate)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel?.text = .none
        self.urlImageView?.image = .none
        self.dateLabel?.text = .none
    }
    
}
