//
//  URLItemBindingObject.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

extension URLItem {
    
    @objc(URLItemBindingObject)
    class BindingObject: NSObject, URLItemType {
        
        var realmID: String
        var cloudKitID: String?
        
        var urlString: String {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).urlString
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.urlString = newValue
                }
            }
        }
        
        var modificationDate: Date {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).modificationDate
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.modificationDate = Date() // not actually needed because this is done by the class method
                }
            }
        }
        
        var archived: Bool {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).archived
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.archived = newValue
                }
            }
        }
        
        var tags: [TagItemType] {
            get {
                return URLRealmItemStorer.realmObject(withID: self.realmID).tags
            }
            set {
                URLRealmItemStorer.updateRealmObject(withID: self.realmID) { object in
                    object.tags = newValue
                }
            }
        }
        
        override init() {
            self.realmID = URLRealmItemStorer.idForNewRealmObject()
            super.init()
        }
        
        init(realmID: String) {
            self.realmID = realmID
            super.init()
        }
    }
}
