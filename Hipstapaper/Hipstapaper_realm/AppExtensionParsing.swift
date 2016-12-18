//
//  AppExtensionParsing.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

struct InterimURLObject {
    
    var urlString: String?
    var image: UIImage?
    var title: String?
    
    static func interimURL(from item: NSExtensionItem, handler: @escaping (InterimURLObject?) -> Void) {
        // since this is all async, we need to make sure we return only when the object is full
        // hitcount goes from 0 to 2, because there are 3 properties of this object
        var hitCount = 0
        var interimURL = InterimURLObject() {
            didSet {
                if hitCount >= 2 {
                    handler(interimURL)
                    return
                }
                hitCount += 1
            }
        }
        
        // set the title on the object
        interimURL.title = item.attributedContentText?.string
        
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
            interimURL.urlString = url?.absoluteString
        }
        
        // load a preview image for the object
        let desiredImageSize = NSValue(cgSize: CGSize(width: 1024, height: 768))
        attachment.loadPreviewImage(options: [NSItemProviderPreferredImageSizeKey : desiredImageSize]) { secureCoding, error in
            let image = secureCoding as? UIImage
            interimURL.image = image
        }
    }
}
