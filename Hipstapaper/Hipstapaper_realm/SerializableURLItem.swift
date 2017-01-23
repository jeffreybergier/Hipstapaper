//
//  SerializableURLItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//
#if os(OSX)
    import AppKit
#else
    import UIKit
    import MobileCoreServices
#endif
import Foundation

@objc(SerializableURLItem) // needed so the object can be archived/unarchived across modules
class SerializableURLItem: NSObject, NSCoding {
    
    enum Result {
        case success(SerializableURLItem), error
    }
    
    #if os(OSX)
    private static let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
    #else
    private static let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
    #endif
    static let archiveURL: URL = {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SerializableURLItem.appGroupIdentifier)!
        let archiveURL = directory.appendingPathComponent("ItemsToSave.bin")
        return archiveURL
    }()
    
    var urlString: String?
    var date: Date? = Date()
    var pageTitle: String?
    #if os(OSX)
    var image: NSImage?
    #else
    var image: UIImage?
    #endif
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        if let urlString = coder.decodeObject(forKey: "URLString") as? String {
            self.urlString = urlString
        } else {
            return nil
        }
        self.date = coder.decodeObject(forKey: "Date") as? Date
        self.pageTitle = coder.decodeObject(forKey: "PageTitle") as? String
        #if os(OSX)
            self.image = coder.decodeObject(forKey: "Image") as? NSImage
        #else
            self.image = coder.decodeObject(forKey: "Image") as? UIImage
        #endif
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.urlString, forKey: "URLString")
        coder.encode(self.date, forKey: "Date")
        coder.encode(self.pageTitle, forKey: "PageTitle")
        coder.encode(self.image, forKey: "Image")
    }
    
    
}

extension SerializableURLItem {
    
    static func item(from extensionItem: NSExtensionItem, handler: @escaping (Result) -> Void) {
        // create the object to return
        let outputItem = SerializableURLItem()
        
        // get the title
        outputItem.pageTitle = extensionItem.attributedContentText?.string
        
        // since this is all async, we need to make sure we return only when the object is full
        // hitcount goes from 0 to 2, because there are 3 properties of this object
        let itemCount = extensionItem.attachments?.count ?? 0
        var hitCount = 0 {
            didSet {
                guard hitCount == itemCount * 2 else { return }
                DispatchQueue.main.async {
                    // our object is valid
                    if let urlString = outputItem.urlString, let _ = URL(string: urlString) {
                        handler(.success(outputItem))
                    } else {
                        handler(.error)
                    }
                }
            }
        }
        
        // if the number of attached items is 0, we need to trigger the exit by calling didSet on hitcount
        guard itemCount > 0 else { hitCount = 0; return; }
        
        // make sure we have an attachment
        // if not, return nil
        guard let attachments = extensionItem.attachments as? [NSItemProvider] else { handler(.error); return; }
        for attachment in attachments.reversed() {
            // load the URL for the object
            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: .none) { secureCoding, error in
                //https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
                // public.url (kUTTypeURL) public.data 'url'   Uniform Resource Locator.
                //      this one finds File and Web Page URLs
                // public.file-url (kUTTypeFileURL)    public.url  'furl'  File URL.
                //      this one finds only File URLs and not web pages
                // public.url-name -   'urln'  URL name.
                //      not sure what this one does, it didn't find either
                
                let url = secureCoding as? URL
                if let urlString = url?.absoluteString {
                    outputItem.urlString = urlString
                }
                hitCount += 1
            }
            
            // load a preview image for the object
            #if os(OSX)
                let desiredImageSize = NSValue(size: NSSize(width: 512, height: 512))
            #else
                let desiredImageSize = NSValue(cgSize: CGSize(width: 512, height: 512))
            #endif
            attachment.loadPreviewImage(options: [NSItemProviderPreferredImageSizeKey : desiredImageSize]) { secureCoding, error in
                #if os(OSX)
                    let discoveredImage = secureCoding as? NSImage
                #else
                    let discoveredImage = secureCoding as? UIImage
                #endif
                if let discoveredImage = discoveredImage {
                    outputItem.image = discoveredImage
                }
                hitCount += 1
            }
        }
    }
}
