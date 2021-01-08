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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        var success = false {
            didSet {
                switch success {
                case false:
                    // TODO: Fix this
                    fatalError()
                    // self.extensionContext?.cancelRequest(withError: nil)
                case true:
                    self.extensionContext?.completeRequest(returningItems: nil,
                                                           completionHandler: nil)
                }
            }
        }
        
        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            success = false
            return
        }
        context.urlValue() { url in
            guard let url = url else {
                success = false
                return
            }
            
            let snapshotter = Snapshotter(.init(loadURL: url)) { result in
                switch result {
                case .failure(let error):
                    // TODO: Do something with this error
                    success = false
                case .success(let output):
                    print(output)
                    print("DONE")
                    success = true
                }
            }
            
            let vc = UIHostingController(rootView: snapshotter)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(vc.view)
            self.view.addConstraints([
                self.view.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
                self.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0),
                self.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0),
                self.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0)
            ])
            self.addChild(vc)
        }
    }

}
