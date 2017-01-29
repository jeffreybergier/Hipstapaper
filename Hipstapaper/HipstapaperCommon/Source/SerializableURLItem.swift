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
#endif
import Foundation

final public class SerializableURLItem: NSObject, NSCoding {
    
    public enum Result {
        case success(SerializableURLItem), error
    }

    internal static let archiveURL: URL = {
        #if os(OSX)
            let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
        #else
            let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
        #endif
        
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
        let archiveURL = directory.appendingPathComponent("ItemsToSave.bin")
        return archiveURL
    }()
    
    public var urlString: String?
    public var date: Date? = Date()
    public var pageTitle: String?
    #if os(OSX)
    public var image: NSImage?
    #else
    public var image: UIImage?
    #endif
    
    override init() {
        super.init()
    }
    
    private enum Constants {
        static let kPageTitle = "kPageTitleKey"
        static let kURLString = "kURLStringKey"
        static let kDate = "kDateKey"
        static let kImage = "kImageKey"
    }
    
    required public init?(coder: NSCoder) {
        guard let urlString = coder.decodeObject(forKey: Constants.kURLString) as? String else { return nil }
        self.urlString = urlString
        self.date = coder.decodeObject(forKey: Constants.kDate) as? Date
        self.pageTitle = coder.decodeObject(forKey: Constants.kPageTitle) as? String
        #if os(OSX)
            self.image = coder.decodeObject(forKey: Constants.kImage) as? NSImage
        #else
            self.image = coder.decodeObject(forKey: Constants.kImage) as? UIImage
        #endif
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.urlString, forKey: Constants.kURLString)
        coder.encode(self.date, forKey: Constants.kDate)
        coder.encode(self.pageTitle, forKey: Constants.kPageTitle)
        coder.encode(self.image, forKey: Constants.kImage)
    }
    
    
}
