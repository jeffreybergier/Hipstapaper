//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import MobileCoreServices
import UIKit

@objc(URLItemSavingShareViewController)
class URLItemSavingShareViewController: UIViewController {
    
    private enum UIState {
        case start, loggingIn, saving, saved, error
    }
    
    private var uiState = UIState.start {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                    switch self.uiState {
                    case .start:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
                        self.messageLabel?.text = "Logging In"
                    case .loggingIn:
                        self.modalView?.alpha = 0.5
                        self.containerViewVerticalSpaceConstraint?.constant = 250
                        self.messageLabel?.text = "Logging In"
                    case .saving:
                        self.modalView?.alpha = 0.5
                        self.containerViewVerticalSpaceConstraint?.constant = 250
                        self.messageLabel?.text = "Saving"
                    case .error:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = 250
                        self.messageLabel?.text = "Error"
                    case .saved:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = -50
                        self.messageLabel?.text = "Saved"
                    }
                }, completion: .none)
            }
        }
    }
    
    @IBOutlet private var containerViewVerticalSpaceConstraint: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var modalView: UIView?
    @IBOutlet private var containerView: UIView? {
        didSet {
            self.containerView?.layer.shadowColor = UIColor.black.cgColor
            self.containerView?.layer.shadowOffset = CGSize(width: 2, height: 3)
            self.containerView?.layer.shadowOpacity = 0.4
            self.containerView?.layer.cornerRadius = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiState = .start
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.uiState = .loggingIn
        
        RealmConfig.configure() {
            self.uiState = .saving
            
            guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
                DispatchQueue.main.async {
                    self.uiState = .error
                    self.extensionContext?.cancelRequest(withError: NSError())
                }
                return
            }
            
            InterimURLObject.interimURL(from: extensionItem) { interimURL in
                guard let interimURL = interimURL else {
                    DispatchQueue.main.async {
                        self.uiState = .error
                        self.extensionContext?.cancelRequest(withError: NSError())
                    }
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let newURLItem = URLItem()
                    newURLItem.urlString = interimURL.urlString ?? newURLItem.urlString
                    realm.add(newURLItem)
                    try! realm.commitWrite()
                    
                    DispatchQueue.main.async {
                        self.uiState = .saved
                        self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
                    }
                    
                }
            }
        }
    }
    
    @IBAction private func cancel(_ sender: NSObject?) {
        
    }
}

extension URLItemSavingShareViewController {
    
    fileprivate struct InterimURLObject {
        
        var urlString: String?
        var image: UIImage?
        var title: String?
        
        fileprivate static func interimURL(from item: NSExtensionItem, handler: @escaping (InterimURLObject?) -> Void) {
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
}

