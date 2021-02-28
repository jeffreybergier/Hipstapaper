//
//  Created by Jeffrey Bergier on 2021/01/09.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

import Foundation
import Combine

public enum AppGroup {
    public static let dropbox: URL = container.appendingPathComponent("Dropbox", isDirectory: true)
    public static let container: URL = {
        let fm = FileManager.default
        #if os(macOS)
        let id = "V6ESYGU6CV.com.saturdayapps.Hipstapaper"
        #else
        let id = "group.com.saturdayapps.Hipstapaper"
        #endif
        return fm.containerURL(forSecurityApplicationGroupIdentifier: id)!
    }()
}

open class DirectoryPresenter: NSObject, NSFilePresenter {
    open var presentedItemOperationQueue = OperationQueue.main
    open var presentedItemURL: URL?
    open func presentedSubitemDidChange(at url: URL) { }
    public init(url: URL) {
        self.presentedItemURL = url
    }
}

open class DirectoryPublisher: DirectoryPresenter {
    
    private var _publisher = PassthroughSubject<URL, Never>()
    open lazy var publisher: AnyPublisher<URL, Never> = {
        var setupPerformed = false
        return AnyPublisher(_publisher.handleEvents(receiveSubscription:
        { [unowned self] subs in
            guard !setupPerformed else { return }
            setupPerformed = true
            self.setupOnce()
        }))
    }()
    
    open func setupOnce() {
        let fm = FileManager.default
        let existingContents = try? fm.contentsOfDirectory(
            at: self.presentedItemURL!,
            includingPropertiesForKeys: [.isRegularFileKey, .isHiddenKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        )
        NSFileCoordinator.addFilePresenter(self)
        for url in existingContents ?? [] {
            let check = try? url.resourceValues(forKeys: [.isRegularFileKey, .isHiddenKey])
            guard check?.isRegularFile == true && check?.isHidden == false else { continue }
            self.presentedItemOperationQueue.underlyingQueue!.async {
                self._publisher.send(url)
            }
        }
    }
    
    public override func presentedSubitemDidChange(at url: URL) {
        let check = try? url.resourceValues(forKeys: [.isRegularFileKey, .isHiddenKey])
        guard check?.isRegularFile == true && check?.isHidden == false else { return }
        _publisher.send(url)
    }
}
