//
//  Created by Jeffrey Bergier on 2021/01/08.
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

import UIKit
import SwiftUI
import Snapshot

class ShareViewController: UIViewController {
    
    private let viewModel = Snapshot.ViewModel()
    private lazy var snapshotVC: UIViewController = UIHostingController(rootView: Snapshotter(self.viewModel))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        let vc = self.snapshotVC
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(vc.view)
        self.view.addConstraints([
            self.view.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
            self.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0),
            self.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0),
            self.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0)
        ])
        self.addChild(vc)
        
        self.viewModel.doneAction = { result in
            switch result {
            case .failure(let error):
                // TODO: Do something with this error
                self.extensionContext?.completeRequest(returningItems: nil,
                                                       completionHandler: nil)
            case .success(let output):
                do {
                    let dropbox = AppGroup.dropbox
                    let dateString = ISO8601DateFormatter().string(from: Date())
                    let data = try PropertyListEncoder().encode(output)
                    let fm = FileManager.default
                    try fm.createDirectory(at: dropbox,
                                           withIntermediateDirectories: true,
                                           attributes: nil)
                    let dataURL = dropbox.appendingPathComponent(dateString + ".plist")
                    try! data.write(to: dataURL)
                } catch {
                    print(error)
                }
                self.extensionContext?.completeRequest(returningItems: nil,
                                                       completionHandler: nil)
            }
            
        }
        
        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.extensionContext?.completeRequest(returningItems: nil,
                                                   completionHandler: nil)
            return
        }
        
        context.urlValue() { url in
            guard let url = url else {
                self.extensionContext?.completeRequest(returningItems: nil,
                                                       completionHandler: nil)
                return
            }
            self.viewModel.setInputURL(url)
        }
    }

}
