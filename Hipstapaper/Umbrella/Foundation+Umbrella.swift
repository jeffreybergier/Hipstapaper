//
//  Foundation+Umbrella.swift
//  Umbrella
//
//  Created by Jeffrey Bergier on 2021/02/17.
//

import Foundation

extension String {
    public var nonEmptyString: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
