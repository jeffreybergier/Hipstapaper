//
//  Created by Jeffrey Bergier on 2021/01/09.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import Combine
import Umbrella
import Snapshot
import Datum

class DropboxWatcher {
    
    let observer: DirectoryPublisher
    private var token: AnyCancellable?
    
    init(controller: Controller, errorQ: ErrorQueue) {
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
                errorQ?.queue.append(Error.shareExtensionAdd)
            }
        }
    }
}
