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

import AppKit
import SwiftUI
import Snapshot
import Stylize

class ShareViewController: NSViewController {

    private let viewModel = Snapshot.ViewModel()
    private let errorViewModel = STZ.ERR.Legacy.ViewModel()
    private lazy var snapshotVC: NSViewController = NSHostingController(rootView: Snapshotter(self.viewModel))
    private lazy var errorVC: NSViewController = NSHostingController(rootView: STZ.ERR.Legacy.Presenter(self.errorViewModel))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorViewModel.dismissAction = { [unowned self] error in
            self.extensionContext?.cancelRequest(withError: error)
        }
        
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
                    self.errorViewModel.error = error
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
                    self.errorViewModel.error = Snapshot.Error.sx_save
                }
            }
            
        }
        
        guard let context = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.errorViewModel.error = Snapshot.Error.sx_process
            return
        }
        
        context.urlValue() { url in
            guard let url = url else {
                self.errorViewModel.error = Snapshot.Error.sx_process
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
