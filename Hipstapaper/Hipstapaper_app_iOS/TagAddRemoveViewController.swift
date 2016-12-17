//
//  TabAddRemoveViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class TagAddRemoveViewController: UIViewController {
    
    class func viewController(popoverSource: UIBarButtonItem, items: [URLItem]) -> UIViewController {
        let tagVC = TagAddRemoveViewController()
        let navVC = UINavigationController(rootViewController: tagVC)
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController!.barButtonItem = popoverSource
        navVC.presentationController!.delegate = tagVC
        return navVC
    }
    
    override var preferredContentSize: CGSize {
        get { return CGSize(width: 300, height: 400) }
        set { fatalError("Something is trying to set the preferredContentSize of: \(self)") }
    }
    
    @IBOutlet private weak var tableView: UITableView?
    
    private var items = [URLItem]()
    
    convenience init(items: [URLItem]) {
        self.init()
        self.items = items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure dismiss buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelBBITapped(_:)))
    }
    
    @objc private func doneBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: .none)
    }
    
    @objc private func cancelBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: .none)
    }
}

extension TagAddRemoveViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}

extension TagAddRemoveViewController: UIAdaptivePresentationControllerDelegate {
    // Returning UIModalPresentationNone will indicate that an adaptation should not happen.
    // @available(iOS 8.3, *)
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


