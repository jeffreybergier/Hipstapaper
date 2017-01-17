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
            guard
                let button = self.filterPopupButton,
                let selection = URLItem.ArchiveFilter(rawValue: button.selectedItem?.tag ?? 55)
            else { return URLItem.ArchiveFilter.unarchived }
            return selection
        }
        set {
            let item = self.filterPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.filterPopupButton?.select(item)
        }
    }
    
    var sortOrder: URLItem.SortOrder {
        get {
            guard
                let button = self.sortOrderPopupButton,
                let selection = URLItem.SortOrder(rawValue: button.selectedItem?.tag ?? 55)
            else { return URLItem.SortOrder.recentlyAddedOnTop }
            return selection
        }
        set {
            let item = self.sortOrderPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.sortOrderPopupButton?.select(item)
        }
    }
    
    @IBOutlet private weak var sortOrderPopupButton: NSPopUpButton?
    @IBOutlet private weak var filterPopupButton: NSPopUpButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureSortOrderPopupButton()
        self.configureFilterPopupButton()
    }
    
    private func configureSortOrderPopupButton() {
        for i in 0 ..< URLItem.SortOrder.count {
            guard let sort = URLItem.SortOrder(rawValue: i) else { continue }
            let item = NSMenuItem(title: sort.displayName, action: .none, keyEquivalent: "")
            item.tag = sort.rawValue
            self.sortOrderPopupButton?.menu?.addItem(item)
        }
    }
    
    private func configureFilterPopupButton() {
        for i in 0 ..< URLItem.ArchiveFilter.count {
            guard let filter = URLItem.ArchiveFilter(rawValue: i) else { continue }
            let item = NSMenuItem(title: filter.displayName, action: .none, keyEquivalent: "")
            item.tag = filter.rawValue
            self.filterPopupButton?.menu?.addItem(item)
        }
    }
    
    @IBAction private func sortOrderChosen(_ sender: NSObject?) {
        // check if the new selection is different before notifying the delegate
        guard self.sortOrder != self.delegate?.sortOrder else { return }
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: self.sortOrder, filter: .none, sender: .tertiaryVC)
    }
    
    @IBAction func filterChosen(_ sender: NSObject?) {
        // check if the new selection is different before notifying the delegate
        guard self.filter != self.delegate?.filter else { return }
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: .none, filter: self.filter, sender: .tertiaryVC)
    }
}
