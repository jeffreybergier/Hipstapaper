//
//  Realm.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Foundation

class URLItem: Object {
    
    dynamic var uuid = UUID().uuidString
    dynamic var title = "Unknown Page"
    dynamic var urlString = "http://www.url.com"
    dynamic var archived = false
    dynamic var modificationDate = Date()
    dynamic var creationDate = Date()
    private dynamic var imageData: Data?
    
    static let imageDate: UIImage? = nil
    
    var image: UIImage? {
        get {
            guard let data = self.imageData else { return .none }
            let image = UIImage(data: data)
            return image
        }
        set {
            guard let image = newValue else { self.imageData = .none; return }
            let data = UIImagePNGRepresentation(image)
            self.imageData = data
        }
    }
    
    var tags = List<TagItem>()
    
    override class func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    override static func primaryKey() -> String {
        return "uuid"
    }
    
}

class TagItem: Object {
    
    class func normalize(nameString: String) -> String? {
        let lowerCase = nameString.lowercased()
        let characterSet = CharacterSet.alphanumerics.inverted
        let trimmed = lowerCase.components(separatedBy: characterSet).joined(separator: "")
        if trimmed == "" { return .none } else { return trimmed }
    }
    
    static let normalizedName = ""
    
    private dynamic var normalizedName = "untitled"
    
    var name: String {
        get {
            return self.normalizedName
        }
        set {
            let adjusted = type(of: self).normalize(nameString: newValue) ?? "untitled"
            self.normalizedName = adjusted
        }
    }
    
    let items = LinkingObjects(fromType: URLItem.self, property: "tags")
    
    override class func ignoredProperties() -> [String] {
        return ["name"]
    }
    
}

struct RealmConfig {
//    #if os(OSX)
//    private static let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
//    #else
//    private static let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
//    #endif
//    let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: RealmConfig.appGroupIdentifier)!
//    let realmPath = directory.appendingPathComponent("db.realm")
//    var config = Realm.Configuration.defaultConfiguration
//    config.fileURL = realmPath
    
    static func configure(completionHandler: @escaping (() -> Void)) {
        SyncUser.logIn(with: SyncCredentials.usernamePassword(username: realmUsername, password: realmPassword, register: false), server: realmAuthServer) { user, error in
            DispatchQueue.main.async {
                guard let user = user else { fatalError("\(error!)") }
                let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: realmDataServer.absoluteString)!))
                Realm.Configuration.defaultConfiguration = config
                completionHandler()
            }
        }
    }
}


