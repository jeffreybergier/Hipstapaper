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

import Foundation
import Combine

public enum AppGroup {
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
            guard check?.isRegularFile == true && check?.isHidden == false else { return }
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
