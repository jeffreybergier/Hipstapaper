//
//  Created by Jeffrey Bergier on 2020/11/23.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import CoreData
import Umbrella
import V3Model

@objc(CD_Base) internal class CD_Base: NSManagedObject, Identifiable {

    /// Template for fetch request in subclasses
    internal class var entityName: String { "CD_Base" }
    private class var request: NSFetchRequest<CD_Base> {
        NSFetchRequest<CD_Base>(entityName: self.entityName)
    }

    @NSManaged internal var cd_dateCreated: Date?
    @NSManaged internal var cd_dateModified: Date?

    override internal func awakeFromInsert() {
        super.awakeFromInsert()
        let date = Date()
        self.cd_dateModified = date
        self.cd_dateCreated = date
    }
    
    override func willSave() {
        super.willSave()
        
        let now = Date()
        
        if self.cd_dateCreated == nil {
            NSLog("Date was NIL")
            self.cd_dateCreated = now
        }
        
        if self.cd_dateModified == nil {
            NSLog("Date was NIL")
            self.cd_dateModified = now
        }
        
        if abs(self.cd_dateModified!.timeIntervalSince(now)) > 3 {
            self.cd_dateModified = now
        }
    }
}

extension Tag.Identifier {
    internal init(_ id: NSManagedObjectID) {
        self.init(id.uriRepresentation().absoluteString, kind: .user)
    }
}

extension Website.Identifier {
    internal init(_ id: NSManagedObjectID) {
        self.init(rawValue: id.uriRepresentation().absoluteString)
    }
}
