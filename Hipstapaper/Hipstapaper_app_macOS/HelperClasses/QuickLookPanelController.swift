//
//  QuickLookPanelController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2/11/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit
import Quartz

class QuickLookPanelController: NSResponder {
    
    var previewItems = [QLPreviewItem]() {
        didSet {
            guard let controller = QLPreviewPanel.shared().currentController as AnyObject?, controller === self else { return }
            QLPreviewPanel.shared()?.reloadData()
        }
    }
    
    weak var delegate: QLPreviewPanelDelegate?
    weak var dataSource: QLPreviewPanelDataSource?
    
    func togglePanel(_ sender: Any?) {
        guard let panel = QLPreviewPanel.shared() else { return }
        if panel.isVisible == true {
            panel.close()
        } else {
            panel.makeKeyAndOrderFront(sender)
        }
    }
    
}

extension QuickLookPanelController /*:  QLPreviewPanelController*/ {
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel?) -> Bool {
        return true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel?) {
        panel?.dataSource = self.dataSource ?? self
        panel?.delegate = self.delegate ?? self
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel?) {
        panel?.dataSource = .none
        panel?.delegate = .none
    }
}

extension QuickLookPanelController: QLPreviewPanelDataSource {

    func numberOfPreviewItems(in panel: QLPreviewPanel?) -> Int {
        return self.previewItems.count
    }

    func previewPanel(_ panel: QLPreviewPanel?, previewItemAt index: Int) -> QLPreviewItem? {
        return self.previewItems[index]
    }
}

extension QuickLookPanelController: QLPreviewPanelDelegate {
    
}
