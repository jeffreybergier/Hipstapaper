//
//  URLItemArchiveFilter.swift
//  Pods
//
//  Created by Jeffrey Bergier on 1/29/17.
//
//

public extension URLItem {
    
    public enum ArchiveFilter: Int {
        case unarchived = 0, all
        
        public var keyPath: String {
            return #keyPath(URLItem.archived)
        }
        
        public static var count: Int {
            return 2
        }
        
        public var displayName: String {
            switch self {
            case .all:
                return "All"
            case .unarchived:
                return "Unarchived"
            }
        }
    }
}
