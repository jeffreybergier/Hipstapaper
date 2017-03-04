//
//  NSExtensionItemParsing.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

#if os(iOS)
    import MobileCoreServices
#endif
import Foundation

extension SerializableURLItem {
    
    static func item(from extensionItem: NSExtensionItem, handler: @escaping (Result) -> Void) {
        // create the object to return
        let outputItem = SerializableURLItem()
        
        // get the title and the content
        // afterward we might overwrite the things with the attachments
        // the attachments are more precise, but not always there
        outputItem.pageTitle = extensionItem.attributedTitle?.string ?? extensionItem.attributedContentText?.string
        outputItem.urlString = URL.webURL(fromURLString: extensionItem.attributedContentText?.string)?.absoluteString
        
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
            attachment.loadURL() { url in
                if let urlString = url?.absoluteString {
                    outputItem.urlString = urlString
                    hitCount += 1 // only do this hitcount if we found the url
                } else {
                    // sometimes the extension only provides the URL as a plain text object
                    // if we don't find a real URL, we will fall back to the plain text
                    attachment.loadURLString() { urlString in
                        let urlString = urlString
                        if let urlString = urlString {
                            outputItem.urlString = urlString
                            outputItem.pageTitle = nil // in this case the page title was actually the URL, so clear it out
                        }
                        hitCount += 1 // always do this hitcount because if we fail we need to move on
                    }
                }
            }
            
            // load a preview image for the object
            attachment.loadImage() { image in
                if let image = image {
                    outputItem.image = image
                }
                hitCount += 1
            }
        }
    }
}

fileprivate extension URL {
    fileprivate static func webURL(fromURLString urlString: String?) -> URL? {
        let urlString = urlString ?? "A Z A"
        guard let components = URLComponents(string: urlString) else { return URL(string: urlString) }
        if let _ = components.host {
            // if we have a host then the URLString was properly formatted
            return components.url
        } else {
            // otherwise we need to add http to the beginning and try again
            let newString = "http://" + urlString
            let url = URL(string: newString)
            return url
        }
    }
}

fileprivate extension NSItemProvider {
    fileprivate func loadURL(_ completion: @escaping (URL?) -> Void) {
        //https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
        // public.url (kUTTypeURL) public.data 'url'   Uniform Resource Locator.
        //      this one finds File and Web Page URLs
        // public.file-url (kUTTypeFileURL)    public.url  'furl'  File URL.
        //      this one finds only File URLs and not web pages
        // public.url-name -   'urln'  URL name.
        //      not sure what this one does, it didn't find either
        self.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { secureCoding, _ in
            let url = secureCoding as? URL
            DispatchQueue.main.async {
                completion(url)
            }
        }
    }
    
    fileprivate func loadURLString(_ completion: @escaping (String?) -> Void) {
        self.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { secureCoding, _ in
            let urlString = (secureCoding as? String) ?? "z   A  z A" //fallback to non URL compatible string
            let url = URL(string: urlString)
            DispatchQueue.main.async {
                completion(url?.absoluteString)
            }
        }
    }
    
    fileprivate func loadImage(_ completion: @escaping (XPImage?) -> Void) {
        // load a preview image for the object
        let desiredImageSize = NSValue(xpSizeWidth: 512, xpSizeHeight: 512)
        self.loadPreviewImage(options: [NSItemProviderPreferredImageSizeKey : desiredImageSize]) { secureCoding, _ in
            let discoveredImage = secureCoding as? XPImage
            DispatchQueue.main.async {
                completion(discoveredImage)
            }
        }
    }
}
