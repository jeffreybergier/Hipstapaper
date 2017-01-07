//
//  SortSelectingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/5/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Cocoa

class SortSelectingViewController: NSViewController {
    
    weak var delegate: URLItemsToLoadChangeDelegate?
    
    var filter: URLItem.ArchiveFilter {
        get {
            guard let button = self.filterPopupButton, let selection = URLItem.ArchiveFilter(rawValue: button.selectedItem?.tag ?? 55) else { return URLItem.ArchiveFilter.unarchived }
            return selection
        }
        set {
            let item = self.filterPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.filterPopupButton?.select(item)
        }
    }
    
    var sortOrder: URLItem.SortOrderA {
        get {
            guard let button = self.sortOrderPopupButton, let selection = URLItem.SortOrderA(rawValue: button.selectedItem?.tag ?? 55) else { return URLItem.SortOrderA.recentlyAddedOnTop }
            return selection
        }
        set {
            let item = self.sortOrderPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.sortOrderPopupButton?.select(item)
        }
    }
    
    @IBOutlet private weak var sortOrderPopupButton: NSPopUpButton?
    @IBOutlet private weak var filterPopupButton: NSPopUpButton?
    
    @IBAction private func sortOrderChosen(_ sender: NSObject?) {
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: self.sortOrder, filter: .none, sender: sender)
    }
    
    @IBAction func filterChosen(_ sender: NSObject?) {
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: .none, filter: self.filter, sender: sender)
    }
}
