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

import CoreData
import Combine
import CloudKit
import Umbrella

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

@available(iOS 14.0, OSX 11.0, *)
internal class CD_SyncMonitor: SyncMonitor {
    
    internal var isLoggedIn: Bool = false
    internal let progress: Progress
    internal var errorQ: Queue<LocalizedError> = []
    
    private let syncName = NSPersistentCloudKitContainer.eventChangedNotification
    private let accountName = Notification.Name.CKAccountChanged
    private var io: Set<UUID> = []
    
    internal init(_ container: NSPersistentContainer) {
        self.progress = .init(totalUnitCount: 0)
        self.progress.completedUnitCount = 0
        guard container is NSPersistentCloudKitContainer else { return }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.observeSync(_:)),
                       name: self.syncName,
                       object: container)
        nc.addObserver(self, selector: #selector(self.observeAccount),
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
                    self.errorQ.append(error as NSError)
                }
                switch account {
                case .available:
                    self.isLoggedIn = true
                case .couldNotDetermine, .restricted, .noAccount:
                    fallthrough
                @unknown default:
                    self.isLoggedIn = false
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
                self.errorQ.append(error as NSError)
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
