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
import Umbrella
import Snapshot
import Stylize
import Collections
import Localize

class ShareViewController: NSViewController {
    
    private let viewModel = Snapshot.ViewModel()
    @ErrorQueue private var errorQ
    private lazy var snapshotVC: NSViewController =
        NSHostingController(rootView: Snapshotter(self.viewModel))
    private lazy var errorVC: NSViewController = NSHostingController(rootView: EmptyView().modifier(ErrorPresentation(self.$errorQ.first))
)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = { // Add SnapshotVC
            let vc = self.snapshotVC
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(vc.view)
            self.view.addConstraints([
                self.view.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
                self.view.bottomAnchor.constraint(greaterThanOrEqualTo: vc.view.bottomAnchor, constant: 0),
                self.view.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 0),
                self.view.trailingAnchor.constraint(greaterThanOrEqualTo: vc.view.trailingAnchor, constant: 0),
                self.view.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor, constant: 0),
            ])
            self.addChild(vc)
        }()
        
        _ = { // Add ErrorVC
            let vc = self.errorVC
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(vc.view)
            self.view.addConstraints([
                self.view.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0),
                self.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0),
                self.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0),
                self.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0),
            ])
            self.addChild(vc)
        }()
        
        self.viewModel.doneAction = { [unowned self] result in
            switch result {
            case .failure(let error):
                if case .userCancelled = error {
                    self.extensionContext?.cancelRequest(withError: error)
                } else {
                    self.errorQ.append(error)
                }
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
                    try data.write(to: dataURL)
                    self.extensionContext?.completeRequest(returningItems: nil,
                                                           completionHandler: nil)
                } catch {
                    self.errorQ.append(Snapshot.Error.sx_save)
                }
            }
            
        }
        
        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.errorQ.append(Snapshot.Error.sx_process)
            return
        }
        
        context.urlValue() { url in
            guard let url = url else {
                self.errorQ.append(Snapshot.Error.sx_process)
                return
            }
            self.viewModel.setInputURL(url)
        }
    }

}

extension NSExtensionItem {
    fileprivate func urlValue(completion: @escaping (URL?) -> Void) {
        let contentType = kUTTypeURL as String
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
