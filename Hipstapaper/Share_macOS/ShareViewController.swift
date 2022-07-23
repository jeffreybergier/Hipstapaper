//
//  Created by Jeffrey Bergier on 2021/01/08.
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

import AppKit
import SwiftUI

class ShareViewController: NSViewController {
        
    private lazy var shareUIVC: NSViewController = NSViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = { // Add SnapshotVC
            let vc = self.shareUIVC
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(vc.view)
            self.view.addConstraints([
                self.view.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
                self.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0),
                self.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0),
                self.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0)
            ])
            self.addChild(vc)
        }()
        
        // TODO: How do I dismiss this?
        /*
        self.control.onDone = { [weak extensionContext] in
            extensionContext?.completeRequest(returningItems: nil,
                                              completionHandler: nil)
        }
        */
        
        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            // TODO: Put error back here?
            return
        }
        
        context.urlValue() { url in
            guard let url = url else {
                // TODO: Put error back here?
                return
            }
            // self.control.extensionURL = url
        }
    }
}

import UniformTypeIdentifiers

extension NSExtensionItem {
    fileprivate func urlValue(completion: @escaping (URL?) -> Void) {
        let contentType = UTType.url.identifier
        let _a = self.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(contentType) })
        guard let attachment = _a else {
            completion(nil)
            return
        }
        attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, _ in
            DispatchQueue.main.async {
                guard
                    let data = data as? Data,
                    let urlString = String(data: data, encoding: .utf8),
                    let url = URL(string: urlString)
                else {
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
}
