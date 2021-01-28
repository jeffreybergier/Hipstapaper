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

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

@available(iOS 14.0, OSX 11.0, *)
internal class CD_SyncMonitor: SyncMonitor {
    
    internal let progress: Progress
    internal var errorQ: Queue<LocalizedError> = []
    
    private let name = NSPersistentCloudKitContainer.eventChangedNotification
    private var io: Set<UUID> = []
    
    internal init() {
        self.progress = .init(totalUnitCount: 0)
        self.progress.completedUnitCount = 0
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.observe(_:)),
                       name: self.name,
                       object: nil)
    }
    
    @objc private func observe(_ aNotification: Notification) {
        let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
        guard let event = aNotification.userInfo?[key]
                as? NSPersistentCloudKitContainer.Event else { return }
        DispatchQueue.main.async {
            self.objectWillChange.send()
            if let error = event.error {
                log.error(error)
                let error = CocoaError(error: error as NSError)
                self.errorQ.append(error)
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
        NotificationCenter.default.removeObserver(self, name: self.name, object: nil)
    }
}
