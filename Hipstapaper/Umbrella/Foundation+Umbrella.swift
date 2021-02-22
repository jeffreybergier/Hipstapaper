//
//  Foundation+Umbrella.swift
//  Umbrella
//
//  Created by Jeffrey Bergier on 2021/02/17.
//

import Foundation

extension String {
    /// Trims string with `.whitespacesAndNewlines` and returns NIL if string is empty after trimming
    public var trimmed: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
