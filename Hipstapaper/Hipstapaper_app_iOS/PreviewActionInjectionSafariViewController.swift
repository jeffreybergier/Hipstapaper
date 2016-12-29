//
//  PreviewActionInjectionSafariViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/29/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import SafariServices
import UIKit

class PreviewActionInjectionSafariViewController: SFSafariViewController {
    
    private var myPreviewActions = [UIPreviewActionItem]()
    
    override var previewActionItems: [UIPreviewActionItem] {
        return self.myPreviewActions
    }
    
    convenience init(url URL: URL, previewActions: [UIPreviewActionItem]? = nil) {
        self.init(url: URL, entersReaderIfAvailable: false)
        self.myPreviewActions = previewActions ?? []
    }
    
}
