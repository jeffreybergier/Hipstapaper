//
//  URLListWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit
import AppKit

class URLListWindowController: NSWindowController {
    
    fileprivate let cloudKitComms = CloudKitComms(recordType: "URLItem")
    @IBOutlet private weak var uiBindingObserver: URLListBindingObserver?
    @IBOutlet private weak var tableView: NSTableView?

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
        self.uiBindingObserver?.delegate = self
    }
    
    @IBAction private func refreshButonClicked(sender: NSObject?) { // IB can send anything and swift won't check unless I do.
        self.tableView?.deselectAll(self)
        self.reloadData()
    }
    
    private func reloadData() {
        self.cloudKitComms.reloadData() { result in
            switch result {
            case .success(let records):
                let items = records.map({ URLBindingItem(record: $0) })
                self.uiBindingObserver?.replaceList(list: items)
            case .error(let error):
                NSLog("\(error)")
            }
        }
    }
}

extension URLListWindowController: RecordChangeDelegate {
    func bindingsObserver(_: URLListBindingObserver, didAdd records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.writeToCloudKit(item: $0.record, completionHandler: {_ in}) })
    }
    func bindingsObserver(_: URLListBindingObserver, didChange records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.writeToCloudKit(item: $0.record, completionHandler: {_ in}) })
    }
    func bindingsObserver(_: URLListBindingObserver, didDelete records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.deleteFromCloudKit(item: $0.record, completionHandler: {_ in}) })
    }
}
