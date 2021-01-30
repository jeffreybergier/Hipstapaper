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
    
    private let container: NSPersistentContainer
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
        self.container = container
        self.progress = progress
        self.rc = controller
    }
    
}

private class WM_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_Controller.exportLocation
    }
}
