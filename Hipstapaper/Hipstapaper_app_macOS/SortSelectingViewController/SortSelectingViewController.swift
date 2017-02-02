//
//  SortSelectingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/5/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import Cocoa

class SortSelectingViewController: NSViewController {
    
    // MARK: Delegate
    
    weak var delegate: URLItemsToLoadChangeDelegate?
    
    // MARK: Ivars and Properties
    
    private var _filter = URLItem.ArchiveFilter.unarchived
    var filter: URLItem.ArchiveFilter {
        get {
            return _filter
        }
        set {
            self._filter = newValue
            let item = self.filterPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.filterPopupButton?.select(item)
        }
    }
    
    private var _sortOrder = URLItem.SortOrder.recentlyAddedOnTop
    var sortOrder: URLItem.SortOrder {
        get {
            return _sortOrder
        }
        set {
            self._sortOrder = newValue
            let item = self.sortOrderPopupButton?.menu?.items.filter({ $0.tag == newValue.rawValue }).first
            self.sortOrderPopupButton?.select(item)
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet private weak var sortOrderPopupButton: NSPopUpButton?
    @IBOutlet private weak var filterPopupButton: NSPopUpButton?
    
    // MARK: Initial Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure myself
        self.configureSortOrderPopupButton()
        self.configureFilterPopupButton()
        
        // view did load could be called after these things have been configured by the parent view
        // so just hit that didSet method again to make sure I'm up to date
        self.sortOrder = _sortOrder
        self.filter = _filter
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
    
    // MARK: Extract Info from UI
    
    private func filterFromUI() -> URLItem.ArchiveFilter? {
        guard
            let button = self.filterPopupButton,
            let selection = URLItem.ArchiveFilter(rawValue: button.selectedItem?.tag ?? 55)
        else { return .none }
        return selection
    }
    
    private func sortOrderFromUI() -> URLItem.SortOrder? {
        guard
            let button = self.sortOrderPopupButton,
            let selection = URLItem.SortOrder(rawValue: button.selectedItem?.tag ?? 55)
        else { return .none }
        return selection
    }
    
    // MARK: Respond to User Actions
    
    @IBAction private func sortOrderChosen(_ sender: NSObject?) {
        // check if the new selection is different before notifying the delegate
        guard let newValue = self.sortOrderFromUI(), newValue != _sortOrder else { return }
        _sortOrder = newValue
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: self.sortOrder, filter: .none, sender: .tertiaryVC)
    }
    
    @IBAction func filterChosen(_ sender: NSObject?) {
        // check if the new selection is different before notifying the delegate
        guard let newValue = self.filterFromUI(), newValue != _filter else { return }
        _filter = newValue
        self.delegate?.didChange(itemsToLoad: .none, sortOrder: .none, filter: self.filter, sender: .tertiaryVC)
    }
}

class WindowObservingView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        let selector = #selector(ContentListViewController.sortSelectingViewDidMoveToWindow)
        self.nextResponder?.try(toPerform: selector, with: .none)
    }
}
