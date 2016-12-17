//
//  TagAddRemoveTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

protocol TagApplicationChangeDelegate: class {
    func didChangeTagApplication(_: Bool, sender: UITableViewCell)
}

class TagAddRemoveTableViewCell: UITableViewCell {
    
    static let nibName = "TagAddRemoveTableViewCell"
    
    @IBOutlet weak var tagNameLabel: UILabel?
    @IBOutlet weak var tagSwitch: UISwitch?
    
    weak var delegate: TagApplicationChangeDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel?.text
        self.tagSwitch?.isOn = false
    }
    
    @IBAction private func switchTapped(_ sender: NSObject?) {
        guard let sender = sender as? UISwitch else { return }
        self.delegate?.didChangeTagApplication(sender.isOn, sender: self)
    }
    
}
