//
//  Foundation+Umbrella.swift
//  Umbrella
//
//  Created by Jeffrey Bergier on 2021/02/17.
//

import Foundation

extension NSError: LocalizedError {
    public var errorDescription: String? { self.localizedDescription }
    public var failureReason: String? { self.localizedFailureReason }
    public var recoverySuggestion: String? { self.localizedRecoverySuggestion }
}

extension String {
    public var nonEmptyString: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
