//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/7/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

extension UIViewController {
    var isVisible: Bool {
        return self.view.window != nil
    }
    
    // swiftlint:disable:next variable_name
    var isUniquelyVisibleWithinSplitViewController: Bool {
        let isCollapsed = self.splitViewController?.isCollapsed ?? true
        return isCollapsed && self.isVisible
    }
}

extension UITableView {
    func deselectAllRows(animated: Bool) {
        for indexPath in self.indexPathsForSelectedRows ?? [] {
            self.deselectRow(at: indexPath, animated: animated)
        }
    }
}

extension UISearchController {
    var searchString: String? {
        get {
            guard self.isActive == true else { return nil }
            let trimmed = self.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed != "" else { return nil }
            return trimmed
        }
        set {
            if let newValue = newValue {
                self.searchBar.text = newValue
                self.isActive = true
                self.searchBar.becomeFirstResponder()
            } else {
                self.searchBar.text = nil
                self.isActive = false
                self.searchBar.resignFirstResponder()
            }
        }
    }
}

extension UIViewController {
    
    // swiftlint:disable:next opening_brace
    func emergencyDismissPopover(animated animatedDismiss: Bool = false,
                                 thenPresentViewController vc: UIViewController,
                                 animated animatedPresent: Bool = true,
                                 completion: (() -> Void)? = nil)
    {
        let presentVC = {
            self.present(vc, animated: animatedPresent, completion: completion)
        }
        self.emergencyDismissPopover(animated: animatedDismiss, thenDo: presentVC)
    }
    
    func emergencyDismissPopover(animated: Bool = false, thenDo completion: @escaping (() -> Void)) {
        if self.presentedViewController?.modalPresentationStyle == .popover {
            // false makes the emergency dismissal feel more responsive
            self.presentedViewController?.dismiss(animated: animated, completion: { completion() })
        } else {
            completion()
        }
    }
}

enum StateRestorationIdentifier: String {
    // TagList restoration does not work on collapsed splitview controller
    // I cannot figure out how to make the splitview controller fall back to its source list after it restores its state
    case mainSplitViewController, tagListViewController, tagListNavVC, urlListViewController, urlListNavVC, tertiaryPopOverViewController, tertiaryPopOverNavVC, safariViewController, searchController
}
