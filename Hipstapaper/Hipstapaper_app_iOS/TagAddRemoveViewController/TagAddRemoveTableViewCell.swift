//
//  TagAddRemoveTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import UIKit

class TagAddRemoveTableViewCell: UITableViewCell {
    
    static let nibName = "TagAddRemoveTableViewCell"
    
    @IBOutlet weak var tagNameLabel: UILabel?
    @IBOutlet weak var tagSwitch: UISwitch?
    
    var index: Int = -1
    weak var delegate: TagAssignmentChangeDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tagNameLabel?.text = ""
        self.tagSwitch?.isOn = false
    }
    
    @IBAction private func switchTapped(_ sender: NSObject?) {
        guard let sender = sender as? UISwitch else { return }
        self.delegate?.didChangeAssignment(to: sender.isOn, forTagItemAtIndex: self.index)
    }
    
}
