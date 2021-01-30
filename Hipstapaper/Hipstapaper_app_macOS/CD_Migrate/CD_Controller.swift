//
//  Created by Jeffrey Bergier on 2021/01/30.
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
import RealmSwift
import Common

class CD_Controller {
    
    static let exportLocation: URL = {
        return FileManager
            .default
            .urls(for: .downloadsDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Hipstapaper_Export", isDirectory: true)
    }()
    
    private let cd: NSPersistentContainer
    private let rc: RealmController
    private let progress: Progress
    
    init(controller: RealmController, progress: Progress) {
        let container = WM_PersistentContainer(name: "CD_MOM")
        let lock = DispatchSemaphore(value: 0)
        container.loadPersistentStores() { _, error in
            if let error = error {
                fatalError(String(describing: error))
            }
            lock.signal()
        }
        lock.wait()
        self.progress = progress
        self.cd = container
        self.rc = controller
    }
    
    func start(completion: @escaping (Bool) -> Void) {
        let ctx = self.cd.newBackgroundContext()
        self.progress.totalUnitCount = 0
        self.progress.completedUnitCount = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let c = self.rc.url_loadAll(for: .all, sortedBy: .recentlyAddedOnBottom, filteredBy: .all) else {
                print("Failed to start")
                return
            }
            self.progress.totalUnitCount = Int64(c.count)
            var newTags: [String: CD_Tag] = [:]
            for oldSite in c {
                ctx.performAndWait {
                    defer {
                        DispatchQueue.main.async {
                            self.progress.completedUnitCount += 1
                            print("\(self.progress.completedUnitCount) / \(self.progress.totalUnitCount)")
                            if self.progress.completedUnitCount == self.progress.totalUnitCount {
                                completion(true)
                            }
                        }
                    }
                    
                    // Website
                    let newSite = CD_Website(context: ctx)
                    newSite.cd_dateCreated = oldSite.creationDate
                    newSite.cd_dateModified = oldSite.modificationDate
                    newSite.cd_originalURL = URL(string: oldSite.urlString)
                    newSite.cd_title = oldSite.extras?.pageTitle
                    newSite.cd_isArchived = oldSite.archived
                    newSite.cd_thumbnail = oldSite.extras?.imageData
                    
                    // Tag
                    for oldTag in oldSite.tags {
                        var newTag: CD_Tag! = newTags[oldTag.name]
                        if newTag == nil {
                            newTag = CD_Tag(context: ctx)
                            newTag.cd_name = oldTag.name
                            newTag.cd_dateModified = oldSite.modificationDate
                            newTag.cd_dateCreated = oldSite.creationDate
                            newTags[oldTag.name] = newTag
                        }
                        let newSiteTags = newSite.mutableSetValue(forKey: #keyPath(CD_Website.cd_tags))
                        newSiteTags.add(newTag!)
                        newTag.cd_websitesCount = Int32(newTag.cd_websites.count)
                    }
                    
                    do {
                        try ctx.save()
                    } catch {
                        fatalError(String(describing: error))
                    }
                }
            }
        }
    }
}

private class WM_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.exportLocation
    }
}
