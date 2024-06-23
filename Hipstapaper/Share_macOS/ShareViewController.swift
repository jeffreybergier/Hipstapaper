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

// TODO: Remove when possible
@preconcurrency import Foundation
import AppKit
import SwiftUI
import V3WebsiteEdit

// TODO: Remove when possible
extension NSExtensionContext: @retroactive @unchecked Sendable {}

@MainActor
class ShareViewController: NSViewController {
    
    private var inputURL: URL?
    private lazy var shareUIVC: NSViewController = {
        let view = ShareExtension(inputURL: self.inputURL)
        { [weak extensionContext] in
            extensionContext?.completeRequest(returningItems: nil,
                                              completionHandler: nil)
        }
        return NSHostingController(rootView: view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.configureVC()
            assertionFailure("Could not get extension context")
            return
        }
        context.urlValue() { url in
            self.inputURL = url
            self.configureVC()
        }
    }
    
    private func configureVC() {
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
    }
}

import UniformTypeIdentifiers

extension NSExtensionItem {
    @MainActor
    fileprivate func urlValue(completion: @escaping (URL?) -> Void) {
        let contentType = UTType.url.identifier
        let _a = self.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(contentType) })
        guard let attachment = _a else {
            completion(nil)
            return
        }
        
        Task {
            let _data = try? await attachment.loadItem(forTypeIdentifier: contentType, options: nil)
            guard
                let data = _data as? Data,
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
