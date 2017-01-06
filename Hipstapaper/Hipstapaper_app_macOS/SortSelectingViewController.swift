//
//  SortSelectingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/5/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Cocoa

class SortSelectingViewController: NSViewController {

    @IBOutlet private weak var sortOrderPopupButton: NSPopUpButton?
    @IBOutlet private weak var filterPopupButton: NSPopUpButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func sortOrderChosen(_ sender: NSObject?) {
        guard let button = sender as? NSPopUpButton, button === self.sortOrderPopupButton, let selection = SortOrderSelection(rawValue: button.selectedItem?.tag ?? 55) else { return }
        print("Sort Order Chosen: \(selection)")
    }
    
    @IBAction func filterChosen(_ sender: NSObject?) {
        guard let button = sender as? NSPopUpButton, button === self.filterPopupButton, let selection = FilterSelection(rawValue: button.selectedItem?.tag ?? 55) else { return }
        print("Sort Order Chosen: \(selection)")
    }
}

enum FilterSelection: Int {
    case unarchived = 0, all
}

enum SortOrderSelection: Int {
    case recentlyAddedOnTop = 2, recentlyAddedOnBottom = 3, recentlyModifiedOnTop = 4, recentlyModifiedOnBottom = 5, urlAOnTop = 6, urlZOnTop = 7
}
