//
//  Created by Jeffrey Bergier on 2021/01/09.
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


import Combine
import Umbrella
import Snapshot
import Datum

class DropboxWatcher {
    
    let observer: DirectoryPublisher
    private var token: AnyCancellable?
    
    init(controller: Controller, errorQ: ErrorQ) {
        let dropbox = AppGroup.dropbox
        let fm = FileManager.default
        try? fm.createDirectory(at: dropbox,
                                withIntermediateDirectories: true,
                                attributes: nil)
        self.observer = DirectoryPublisher(url: dropbox)
        self.token = self.observer.publisher.sink() { [weak errorQ] url in
            do {
                let data = try Data(contentsOf: url)
                let output = try PropertyListDecoder().decode(Snapshot.ViewModel.Output.self, from: data)
                _ = try controller.createWebsite(.init(output)).get()
                try FileManager.default.removeItem(at: url)
            } catch {
                log.error(error)
                errorQ?.append(Error.shareExtensionAdd)
            }
        }
    }
}
