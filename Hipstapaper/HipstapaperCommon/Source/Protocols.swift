//
//  Protocols.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

import Foundation

public protocol RealmControllable: class {
    var realmController: RealmController? { get set }
}

public protocol URLItemsToLoadChangeDelegate: class {
    var itemsToLoad: URLItem.ItemsToLoad { get }
    var filter: URLItem.ArchiveFilter { get }
    var sortOrder: URLItem.SortOrder { get }
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender)
}

public enum ViewControllerSender {
    case sourceListVC, contentVC, tertiaryVC
}
