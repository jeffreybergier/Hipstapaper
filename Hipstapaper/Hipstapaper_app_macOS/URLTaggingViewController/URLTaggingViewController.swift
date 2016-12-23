//
//  URLTaggingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/23/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

@objc(TagSelection)
fileprivate class TagSelection: NSObject {
    
    var state: NSCellStateValue = 0 {
        didSet {
            guard let oldState = CheckboxState(rawValue: oldValue), let newState = CheckboxState(rawValue: self.state) else { return }
            
            // if the new state is mixed, we need to figure out if it should be on or off
            // annoyingly the checkbox cell allows a mixed state setting when the user clicks
            if case .mixed = newState {
                let keyPath = #keyPath(TagSelection.name)
                self.willChangeValue(forKey: keyPath)
                switch oldState {
                case .off, .mixed:
                    self.state = CheckboxState.on.rawValue
                case .on:
                    self.state = CheckboxState.off.rawValue
                }
                self.didChangeValue(forKey: keyPath)
            }
        }
    }
    var name: String = "unknown"
    
    convenience init(name: String, state: NSCellStateValue) {
        self.init()
        self.state = state
        self.name = name
    }
    
    static func selections(of tagItems: [TagItem], for urlItems: [URLItem]?) -> [TagSelection] {
        let urlItems = urlItems ?? []
        let selections = tagItems.map() { tagItem -> TagSelection in
            let state = RealmConfig.state(of: tagItem, with: urlItems)
            let selection = TagSelection(name: tagItem.name, state: state.rawValue)
            return selection
        }
        return selections
    }
    
}

class URLTaggingViewController: NSViewController {
    
    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            let key = #keyPath(TagSelection.name)
            let selector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: key, ascending: true, selector: selector)]
        }
    }
    
    private var selectedItems = [URLItem]()
    
    convenience init(items: [URLItem]) {
        self.init()
        self.selectedItems = items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hardReloadData()
    }
    
    // MARK: Reload Data
    
    private func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.arrayController?.content = []
        
        let realm = try! Realm()
        let items = realm.objects(TagItem.self)
        self.notificationToken = items.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial(let results):
            let selections = TagSelection.selections(of: Array(results), for: self?.selectedItems)
            self?.arrayController?.content = selections
        case .update(let results, _, _, _):
            let selections = TagSelection.selections(of: Array(results), for: self?.selectedItems)
            self?.arrayController?.content = selections
        case .error(let error):
            fatalError("\(error)")
        }
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}
