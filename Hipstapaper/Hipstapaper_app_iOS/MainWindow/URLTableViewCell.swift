//
//  URLItemTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import UIKit

class URLTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 65
    static let withImageNIBName = "URLTableViewCellwIMG"
    static let withOutImageNIBName = "URLTableViewCellwoIMG"
    
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
        self.titleLabel?.text = item.extras?.pageTitle ?? item.urlString
        self.dateLabel?.text = self.dateFormatter.string(from: item.creationDate)
        self.urlImageView?.image = item.extras?.image
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel?.text = .none
        self.urlImageView?.image = .none
        self.dateLabel?.text = .none
    }
    
}
