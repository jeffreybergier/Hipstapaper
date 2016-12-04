//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/3/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence_macOS
import AppKit

extension NSExtensionContext {
    var jsb_inputItems: [NSExtensionItem] {
        return self.inputItems.map({ $0 as? NSExtensionItem }).flatMap({ $0 })
    }
}

extension Sequence where Iterator.Element == NSExtensionItem {
    func mapURLs(completionHandler: @escaping (Result<[URL]>) -> Void) {
        let serialQueue = DispatchQueue(label: UUID().uuidString, qos: .userInitiated)

        serialQueue.async {
            let items = self.map({ $0.attachments?.map({ $0 as? NSItemProvider }) }).flatMap({ $0 }).flatMap({$0}).flatMap({ $0 })
            var allResults: [Result<URL>] = []
//            {
//                didSet {
//                    // adding a didSet here causes a compiler failure
//                }
//            }
            
            for item in items {
                //https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
                //public.url (kUTTypeURL) public.data 'url'   Uniform Resource Locator.
                    // this one finds File and Web Page URLs
                //public.file-url (kUTTypeFileURL)    public.url  'furl'  File URL.
                    // this one finds only File URLs and not web pages
                //public.url-name -   'urln'  URL name.
                    // not sure what this one does, it didn't find either
                item.loadItem(forTypeIdentifier: kUTTypeURL as String) { secureCoding, error in
                    serialQueue.async {
                        if let url = secureCoding as? URL {
                            allResults.append(.success(url))
                        } else {
                            allResults.append(.error([error]))
                        }
                        
                        if allResults.count == items.count {
                            let results = allResults.flatMap()
                            completionHandler(results)
                        }
                    }
                }
            }
        }
    }
}

extension Sequence where Iterator.Element == Result<URL> {
    func flatMap() -> Result<[URL]> {
        let errors = self.mapError()
        if errors.isEmpty == false {
            return .error(errors)
        } else {
            let success = self.mapSuccess()
            return .success(success)
        }
    }
}

extension Sequence where Iterator.Element == Result<URL> {
    func mapSuccess() -> [URL] {
        let items = self.map() { result -> URL? in
            if case .success(let item) = result {
                return item
            }
            return .none
            }.filter({ $0 != nil }).map({ $0! })
        return items
    }
    func mapError() -> [Error] {
        let items = self.map() { result -> [Error]? in
            if case .error(let error) = result {
                return error
            }
            return .none
            }.filter({ $0 != nil }).map({ $0! }).flatMap({ $0 })
        return items
    }
}
