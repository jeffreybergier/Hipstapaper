//
//  RealmManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class URLRealmTag: Object {
    dynamic var name: String = ""
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
}

class URLRealmItem: Object {
    dynamic var id = UUID().uuidString
    dynamic var urlString: String = "http://www.url.com"
    dynamic var archived: Bool = false
    dynamic var modificationDate = Date()
    var tags = List<URLRealmTag>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(urlString: String) {
        self.init()
        self.urlString = urlString
    }
}

class URLBindingItem2: NSObject {
    
    private let realmRecord: URLRealmItem
    
    var id: String {
        return realmRecord.id
    }
    
    var urlString: String {
        get {
            return self.realmRecord.urlString
        }
        set {
            let realm = try! Realm()
            let writableItem = realm.object(ofType: URLRealmItem.self, forPrimaryKey: id)!
            try! realm.write {
                writableItem.urlString = newValue
                writableItem.modificationDate = Date()
            }
        }
    }

    var modificationDate: Date {
        return self.realmRecord.modificationDate
    }
    
    init(realmRecord: URLRealmItem) {
        self.realmRecord = realmRecord
        super.init()
    }
}

class URLRealmItemStorer: NSObject {
    
    private var realmItemIDs: [String]
    
    subscript(index: Int) -> URLBindingItem2 {
        let id = self.realmItemIDs[index]
        let realm = try! Realm()
        let realmItem = realm.object(ofType: URLRealmItem.self, forPrimaryKey: id)!
        let bindingItem = URLBindingItem2(realmRecord: realmItem)
        return bindingItem
    }
    
    override init() {
        let realm = try! Realm()
        let results = realm.objects(URLRealmItem.self)
        let ids = Array(results.map({ $0.id }))
        self.realmItemIDs = ids
        
        super.init()
//        self.addTimer()
        self.modifyStuff()
//        self.readStuff()
    }
    
    func readStuff() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            print("read timer")
            let item = self[3]
            print(item)
        }
    }
    
    func addTimer() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            print("add timer")
            let realm = try! Realm()
            try! realm.write {
                realm.add(URLRealmItem(urlString: "http://www.google.com"))
            }
        }
    }

    func modifyStuff() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            print("modify timer")
            let item = self[3]
            item.urlString = "http://www.apple.com"
        }
    }
}
