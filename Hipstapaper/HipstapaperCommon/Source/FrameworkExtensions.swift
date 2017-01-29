//
//  FrameworkExtensions.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

//import Foundation

public enum XPBackgroundFetchResult: UInt {
    case newData = 0, noData, failed
    
    #if os(iOS)
    var iOSValue: UIBackgroundFetchResult {
        return UIBackgroundFetchResult(rawValue: self.rawValue) ?? .failed
    }
    init(iOSValue: UIBackgroundFetchResult) {
        switch iOSValue {
        case .noData:
            self = .noData
        case .failed:
            self = .failed
        case .newData:
            self = .newData
        }
    }
    #endif
}


// used to show the relationship between URLItems and TagItems in the UI
public enum CheckboxState: Int {
    case mixed = -1
    case off = 0
    case on = 1
    
    public var boolValue: Bool {
        switch self {
        case .on, .mixed:
            return true
        case .off:
            return false
        }
    }
}
