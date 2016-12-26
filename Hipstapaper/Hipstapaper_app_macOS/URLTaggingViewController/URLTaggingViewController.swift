//
//  URLTaggingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/23/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class URLTaggingViewController: NSViewController {
    
    fileprivate var realmController: RealmController?
    
    fileprivate var selectedItems = [URLItem]()
    
    @IBOutlet private weak var horizontalLine: NSView?

    @IBOutlet private weak var arrayController: NSArrayController? {
        didSet {
            let key = #keyPath(TagAssignment.item.name)
            let selector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
            self.arrayController?.sortDescriptors = [NSSortDescriptor(key: key, ascending: true, selector: selector)]
        }
    }
    
    convenience init(items: [URLItem], controller: RealmController) {
        self.init()
        self.realmController = controller
        self.selectedItems = items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.horizontalLine?.layer?.backgroundColor = NSColor.gray.cgColor
        self.hardReloadData()
    }
    
    // MARK: Reload Data
    
    private func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.arrayController?.content = []
        
        let items = self.realmController?.tags
        self.notificationToken = items?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        guard let realmController = self?.realmController else { return }
        switch changes {
        case .initial(let results):
            let selections = TagAssignment.assignments(of: Array(results), for: self?.selectedItems, from: realmController)
            selections.forEach({ $0.delegate = self })
            self?.arrayController?.content = selections
        case .update(let results, _, _, _):
            let selections = TagAssignment.assignments(of: Array(results), for: self?.selectedItems, from: realmController)
            selections.forEach({ $0.delegate = self })
            self?.arrayController?.content = selections
        case .error(let error):
            fatalError("\(error)")
        }
    }
    
    // MARK: Handle Creating New Tag
    
    @objc private func createNewTag(_ sender: NSObject?) {
        guard let button = sender as? NSButton, let realmController = self.realmController else {
            // if we can't respond, just pass it on
            self.nextResponder?.try(toPerform: #selector(self.createNewTag(_:)), with: sender)
            return
        }
        // create the tag naming VC
        let newVC = NewTagNamingViewController()
        newVC.confirm = { [weak self] newName, sender, presentedVC in
            // create the tag
            let tag = realmController.newOrExistingTag(proposedName: newName)
            // add it to the selected items
            realmController.apply(tag: tag, to: self?.selectedItems ?? [])
            // hack because the tableview shows the new tag, but doesn't have the appropriate selection
            // maybe this is a bug in realm notifications?
            Thread.sleep(forTimeInterval: 0.3)
            self?.hardReloadData()
            // dismiss the naming view controller
            presentedVC.dismiss(sender)
        }
        // present the vc
        self.presentViewController(newVC, asPopoverRelativeTo: .zero, of: button, preferredEdge: .minY, behavior: .semitransient)
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension URLTaggingViewController: TagAssignmentChangeDelegate {
    func didChangeAssignment(to newValue: Bool, for tagItem: TagItem) {
        switch newValue {
        case true:
            self.realmController?.apply(tag: tagItem, to: self.selectedItems)
        case false:
            self.realmController?.remove(tag: tagItem, from: self.selectedItems)
        }
    }
}

fileprivate protocol TagAssignmentChangeDelegate: class {
    func didChangeAssignment(to: Bool, for: TagItem)
}

@objc(TagAssignment)
fileprivate class TagAssignment: NSObject {
    
    weak var delegate: TagAssignmentChangeDelegate?
    
    let item: TagItem
    var state: NSCellStateValue {
        didSet {
            // slow this down a little bit so the checkbox animation is not disrupted
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                guard let newState = CheckboxState(rawValue: self.state) else { return }
                self.delegate?.didChangeAssignment(to: newState.boolValue, for: self.item)
            }
        }
    }
    
    init(tagItem item: TagItem, state: NSCellStateValue) {
        self.state = state
        self.item = item
        super.init()
    }
    
    static func assignments(of tagItems: [TagItem], for urlItems: [URLItem]?, from realmController: RealmController) -> [TagAssignment] {
        let urlItems = urlItems ?? []
        let selections = tagItems.map() { tagItem -> TagAssignment in
            let state = realmController.state(of: tagItem, with: urlItems)
            let selection = TagAssignment(tagItem: tagItem, state: state.rawValue)
            return selection
        }
        return selections
    }
    
}