//
//  SaveExtensionFileProcessor.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/29/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

#if os(iOS)
    import UIKit
#endif
import Foundation

public class SaveExtensionFileProcessor {
    
    private var processingInProgress = false
    
    public func processFiles(with realmController: RealmController?, completionHandler: ((XPBackgroundFetchResult) -> Void)? = nil) {
        guard self.processingInProgress == false else {
            completionHandler?(.failed)
            return
        }
        self.processingInProgress = true
        DispatchQueue.global(qos: .background).async {
            guard let realmController = realmController else {
                completionHandler?(.failed)
                self.processingInProgress = false
                return
            }
            guard let itemsOnDisk = NSKeyedUnarchiver.unarchiveObject(withFile: SerializableURLItem.archiveURL.path) as? [SerializableURLItem] else {
                // delete the file if it exists and has incorrect data, or else this could fail forever and never get fixed
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
                completionHandler?(.noData)
                self.processingInProgress = false
                return
            }
            DispatchQueue.main.async {
                for item in itemsOnDisk {
                    guard let urlString = item.urlString else { continue }
                    let newURLItem = URLItem()
                    newURLItem.urlString = urlString
                    newURLItem.creationDate = item.date ?? newURLItem.creationDate
                    newURLItem.modificationDate = item.date ?? newURLItem.modificationDate
                    let newExtras = URLItemExtras()
                    newExtras.image = item.image
                    newExtras.pageTitle = item.pageTitle
                    if newExtras.pageTitle != nil || newExtras.imageData != nil {
                        newURLItem.extras = newExtras
                    }
                    realmController.add(item: newURLItem)
                }
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
                if itemsOnDisk.isEmpty == false {
                    completionHandler?(.newData)
                } else {
                    completionHandler?(.noData)
                }
                self.processingInProgress = false
            }
        }
    }
    
    
}

public enum XPBackgroundFetchResult: UInt {
    case newData = 0, noData, failed
    
    #if os(iOS)
    var iOSValue: UIBackgroundFetchResult {
        return UIBackgroundFetchResult(rawValue: self.rawValue) ?? .failed
    }
    init(iOSValue: UIBackgroundFetchResult) {
        switch iOSValue {
        case .noData:
            self = .noData
        case .failed:
            self = .failed
        case .newData:
            self = .newData
        }
    }
    #endif
}
