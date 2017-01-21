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
    
    fileprivate weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    // MARK: Data
    
    fileprivate var data: Results<TagItem>?
    fileprivate var itemsToTag = [URLItem]()
    
    // MARK: Outlets
    
    @IBOutlet private weak var tableView: NSTableView?
    
    // MARK: Appearance
    
    private lazy var appearanceSwitcher: AppleInterfaceStyleWindowAppearanceSwitcher = AppleInterfaceStyleWindowAppearanceSwitcher(window: self.view.window!)
    
    // MARK: Loading
    
    convenience init(itemsToTag items: [URLItem], controller: RealmController) {
        self.init()
        self.realmController = controller
        self.itemsToTag = items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hardReloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let _ = self.appearanceSwitcher
    }
    
    // MARK: Reload Data
    
    private func hardReloadData() {
        self.data = .none
        self.notificationToken?.stop()
        self.notificationToken = .none
        
        self.data = self.realmController?.tag_loadAll()
        self.notificationToken = self.data?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            self?.tableView?.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            self?.tableView?.beginUpdates()
            self?.tableView?.insertRows(at: IndexSet(insertions), withAnimation: .slideRight)
            self?.tableView?.removeRows(at: IndexSet(deletions), withAnimation: .slideLeft)
            self?.tableView?.reloadData(forRowIndexes: IndexSet(modifications), columnIndexes: IndexSet([0]))
            self?.tableView?.endUpdates()
        case .error(let error):
            guard let window = self?.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: .none)
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
            let tag = realmController.tag_uniqueTag(named: newName)
            // add it to the selected items
            realmController.tag_apply(tag: tag, to: self?.itemsToTag ?? [])
            // hack because the tableview shows the new tag, but doesn't have the appropriate selection
            // maybe this is a bug in realm notifications?
            Thread.sleep(forTimeInterval: 0.3)
            self?.hardReloadData()
            // dismiss the naming view controller
            presentedVC.dismiss(sender)
        }
        // present the vc
        self.presentViewController(newVC, asPopoverRelativeTo: .zero, of: button, preferredEdge: .minY, behavior: .transient)
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

// MARK: NSTableViewDataSource

extension URLTaggingViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.data?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let tagItem = self.data?[row], let realmController = self.realmController else { return .none }
        let state = realmController.tag_applicationState(of: tagItem, on: self.itemsToTag)
        let tagAssignment = TagAssignment(tagItem: tagItem, state: state.rawValue)
        tagAssignment.delegate = self
        return tagAssignment
    }
    
}

// MARK: Handle Input from TableViewCells

fileprivate protocol TagAssignmentChangeDelegate: class {
    func didChangeAssignment(to: Bool, for: TagItem)
}

extension URLTaggingViewController: TagAssignmentChangeDelegate {
    func didChangeAssignment(to newValue: Bool, for tagItem: TagItem) {
        switch newValue {
        case true:
            self.realmController?.tag_apply(tag: tagItem, to: self.itemsToTag)
        case false:
            self.realmController?.tag_remove(tag: tagItem, from: self.itemsToTag)
        }
    }
}

// MARK: Bindings Class for TableViewCells Display/Input

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
}
