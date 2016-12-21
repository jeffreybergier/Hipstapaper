//
//  AppExtensionParsing.swift
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

extension URLItemExtras {
    
    static func extras(from item: NSExtensionItem, handler: @escaping ((URLItemExtras?, String)?) -> Void) {
        // get the title
        var pageTitle: String? = item.attributedContentText?.string
        
        // prepar for async operations
        #if os(OSX)
            var image: NSImage?
        #else
            var image: UIImage?
        #endif
        var urlString: String?
        
        // since this is all async, we need to make sure we return only when the object is full
        // hitcount goes from 0 to 2, because there are 3 properties of this object
        var hitCount = 0 {
            didSet {
                if hitCount == 2 {
                    guard let urlString = urlString else { handler(nil); return; }
                    #if os(OSX)
                        let extras = URLItemExtras(title: pageTitle, image: image)
                    #else
                        let extras = URLItemExtras(title: pageTitle, image: image)
                    #endif
                    if extras.pageTitle != nil || extras.imageData != nil {
                        handler((extras, urlString))
                    } else {
                        handler((nil, urlString))
                    }
                }
            }
        }
        
        // make sure we have an attachment
        // if not, return nil
        guard let attachment = item.attachments?.first as? NSItemProvider else { handler(.none); return; }
        
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
            urlString = url?.absoluteString
            hitCount += 1
        }
        
        // load a preview image for the object
        #if os(OSX)
            let desiredImageSize = NSValue(size: NSSize(width: 1024, height: 1024))
        #else
            let desiredImageSize = NSValue(cgSize: CGSize(width: 1024, height: 768))
        #endif
        attachment.loadPreviewImage(options: [NSItemProviderPreferredImageSizeKey : desiredImageSize]) { secureCoding, error in
            #if os(OSX)
                let discoveredImage = secureCoding as? NSImage
            #else
                let discoveredImage = secureCoding as? UIImage
            #endif
            image = discoveredImage
            hitCount += 1
        }
    }
}
