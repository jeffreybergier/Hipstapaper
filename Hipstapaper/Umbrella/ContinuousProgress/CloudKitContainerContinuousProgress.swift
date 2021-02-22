//
//  Created by Jeffrey Bergier on 2021/01/28.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import CoreData
import Combine
import CloudKit

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

/// Shows continuous progress of CloudKit syncing via NSPersistentCloudKitContainer.
/// Note, this class is not tested because it relies on NSNotificationCenter and other singletons.
public class CloudKitContainerContinuousProgress: ContinousProgress {
    
    public enum Error: UserFacingError {
        case accountStatusCritical(NSError)
        case accountStatus(CKAccountStatus)
        case sync(NSError)
        
        public var errorCode: Int {
            switch self {
            case .accountStatusCritical:
                return 1001
            case .accountStatus:
                return 1002
            case .sync:
                return 1003
            }
        }
        public var title: LocalizedStringKey { "Noun.iCloud" }
        public var message: LocalizedStringKey {
            switch self {
            case .accountStatus:
                return "Phrase.ErroriCloudAccount"
            case .accountStatusCritical(let error), .sync(let error):
                return .init(error.localizedDescription)
            }
        }
    }
    
    public var initializeError: UserFacingError?
    public let progress: Progress
    public var errorQ = ErrorQueue()
    
    private let syncName = NSPersistentCloudKitContainer.eventChangedNotification
    private let accountName = Notification.Name.CKAccountChanged
    private var io: Set<UUID> = []
    
    /// If container is not NSPersistentCloudKitContainer this class never shows any progress.
    public init(_ container: NSPersistentContainer) {
        self.progress = .init(totalUnitCount: 0)
        self.progress.completedUnitCount = 0
        guard container is NSPersistentCloudKitContainer else {
            log.error("CloudKitContainerContinuousProgress can only be show progress of sync with NSPersistentCloudKitContainer")
            return
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.observeSync(_:)),
                       name: self.syncName,
                       object: container)
        nc.addObserver(self,
                       selector: #selector(self.observeAccount),
                       name: self.accountName,
                       object: nil)
        self.observeAccount()
    }
    
    @objc private func observeAccount() {
        guard ISTESTING == false else { return }
        CKContainer.default().accountStatus() { account, error in
            DispatchQueue.main.async {
                self.objectWillChange.send()
                if let error = error {
                    log.error(error)
                    let error = error as NSError
                    self.initializeError = Error.accountStatusCritical(error)
                    return
                }
                switch account {
                case .available:
                    self.initializeError = nil
                case .couldNotDetermine, .restricted, .noAccount:
                    fallthrough
                @unknown default:
                    self.initializeError = Error.accountStatus(account)
                }
            }
        }
    }
    
    @objc private func observeSync(_ aNotification: Notification) {
        let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
        guard let event = aNotification.userInfo?[key]
                as? NSPersistentCloudKitContainer.Event else { return }
        DispatchQueue.main.async {
            self.objectWillChange.send()
            if let error = event.error {
                log.error(error)
                let error = error as NSError
                self.errorQ.queue.append(Error.sync(error))
            }
            if self.io.contains(event.identifier) {
                log.debug("- \(event.identifier)")
                self.io.remove(event.identifier)
                self.progress.completedUnitCount += 1
            } else {
                log.debug("+ \(event.identifier)")
                self.io.insert(event.identifier)
                self.progress.totalUnitCount += 1
            }
            log.debug("progress: \(self.progress.completedUnitCount) / \(self.progress.totalUnitCount)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: self.syncName, object: nil)
        NotificationCenter.default.removeObserver(self, name: self.accountName, object: nil)
        log.verbose()
    }
}
