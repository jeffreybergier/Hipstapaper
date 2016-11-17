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
    
    private var openWindows = [URLBindingItem : URLItemWebViewWindowController]()
    
    convenience init() {
        self.init(windowNibName: "URLListWindowController")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
        self.uiBindingObserver?.delegate = self
    }
    
    @IBAction private func refreshButonClicked(_ sender: NSObject?) { // IB can send anything and swift won't check unless I do.
        self.tableView?.deselectAll(self)
        self.reloadData()
    }
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.uiBindingObserver?.selectedItems else { return }
        for item in selectedItems {
            let wvWC: URLItemWebViewWindowController
            if let oldWC = self.openWindows[item] {
                wvWC = oldWC
            } else {
                let newWC = URLItemWebViewWindowController()
                self.openWindows[item] = newWC
                wvWC = newWC
            }
            wvWC.item = item
            wvWC.showWindow(self)
        }
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
