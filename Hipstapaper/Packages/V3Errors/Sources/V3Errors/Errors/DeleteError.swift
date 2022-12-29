//
//  Created by Jeffrey Bergier on 2022/07/18.
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

import Foundation
import Umbrella
import V3Model
import V3Localize

public enum DeleteRequestError: CustomNSError, CodableErrorConvertible, Codable {
    
    static public var errorDomain = "com.saturdayapps.Hipstapaper.DeleteRequest"
    public var errorCode: Int { 1001 }
    
    case website(Website.Selection)
    case tag(Tag.Selection)
    
    public init?(decode: Umbrella.CodableError) {
        guard let data = decode.arbitraryData else { return nil }
        // TODO: Uh, figure out why the types don't decode securely
        if let id = try? PropertyListDecoder().decode(Website.Selection.self, from: data) {
            self = .website(id)
            return
        }
        if let id = try? PropertyListDecoder().decode(Tag.Selection.self, from: data) {
            self = .tag(id)
            return
        }
        assertionFailure()
        return nil
    }
    
    public var encode: Umbrella.CodableError {
        var output = CodableError(self)
        switch self {
        case .website(let id):
            output.arbitraryData = try? PropertyListEncoder().encode(id)
        case .tag(let id):
            output.arbitraryData = try? PropertyListEncoder().encode(id)
        }
        assert(output.arbitraryData != nil)
        return output
    }
    
    public var websiteID: Website.Selection {
        guard case .website(let id) = self else { return [] }
        return id
    }
    
    public var tagID: Tag.Selection {
        guard case .tag(let id) = self else { return [] }
        return id
    }
}

// TODO: Errors, yuck. So much to do
/*
public struct DeleteTagError: CustomNSError {
    
    public var identifiers: Tag.Selection = []
    internal var onConfirm: OnConfirmation?
    
    public init(_ identifiers: Tag.Selection) {
        self.identifiers = identifiers
    }
        
    // MARK: Protocol conformance
    public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Delete.Tag"
    public var errorCode: Int = 1001
    public var title: LocalizationKey = Noun.deleteTag.rawValue
    public var message: LocalizationKey = Phrase.deleteTagConfirm.rawValue
    public var dismissTitle: LocalizationKey = Verb.dontDelete.rawValue
    public var isCritical: Bool = false
    public var options: [RecoveryOption] {
        return [
            .init(title: Verb.deleteTag.rawValue, isDestructive: true) {
                self.onConfirm?(.deleteTags(self.identifiers))
            }
        ]
    }
}

public struct DeleteWebsiteError: CustomNSError {
    
    public var identifiers: Website.Selection = []
    internal var onConfirm: OnConfirmation?
    
    public init(_ identifiers: Website.Selection) {
        self.identifiers = identifiers
    }
        
    // MARK: Protocol conformance
    public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Delete.Website"
    public var errorCode: Int = 1001
    public var title: LocalizationKey = Noun.deleteWebsite.rawValue
    public var message: LocalizationKey = Phrase.deleteWebsiteConfirm.rawValue
    public var dismissTitle: LocalizationKey = Verb.dontDelete.rawValue
    public var isCritical: Bool = false
    public var options: [RecoveryOption] {
        return [
            .init(title: Verb.deleteWebsite.rawValue, isDestructive: true) {
                self.onConfirm?(.deleteWebsites(self.identifiers))
            }
        ]
    }
}
*/
