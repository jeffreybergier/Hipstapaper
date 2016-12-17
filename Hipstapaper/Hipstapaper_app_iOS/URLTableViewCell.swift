//
//  URLItemTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

extension UITableView {
    var selectedURLItems: [URLItem]? {
        let indexPaths = self.indexPathsForSelectedRows ?? []
        let cells = indexPaths.map({ (self.cellForRow(at: $0) as? URLTableViewCell)?.item }).flatMap({$0})
        if cells.isEmpty { return .none } else { return cells }
    }
    
    func urlItemFor(row indexPath: IndexPath) -> URLItem? {
        let cell = self.cellForRow(at: indexPath) as? URLTableViewCell
        return cell?.item
    }
}

class URLTableViewCell: UITableViewCell {
    
    static let nibName = "URLTableViewCell"

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
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.item = .none
        self.urlLabel?.text = .none
        self.dateLabel?.text = .none
        self.idLabel?.text = .none
    }
    
}
