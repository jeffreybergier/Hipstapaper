//
//  FrameworkExtensions.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

import RealmSwift

public extension Results {
    public func indexes(matchingPredicates predicates: [String]) -> [Int]? {
        let matches = predicates.map({ self.filter($0).first }).flatMap({ $0 })
        let indexes = matches.map({ self.index(of: $0) }).flatMap({ $0 })
        if indexes.isEmpty == true { return .none } else { return indexes }
    }
    
    public func index(matchingPredicate predicate: String) -> Int? {
        guard let match = self.filter(predicate).first else { return .none }
        let index = self.index(of: match)
        return index
    }
}

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
