//
//  Created by Jeffrey Bergier on 2021/02/18.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

/// Add ErrorQueue to environment so any view can append errors.
/// Use ErrorQueuePresenter at a high level in your SwiftUI structure to present errors.
/// This class is not thread-safe. Only use from Main thread.
public class ErrorQueue: ObservableObject {
    
    @Published public var current: IdentBox<UFError>?
    
    public var queue: Queue<UFError> = [] {
        didSet {
            guard internalUpdateInProgress == false else { return }
            self.update()
        }
    }
    
    public init() { }
    
    private var internalUpdateInProgress = false
    public func update() {
        self.internalUpdateInProgress = true
        defer { self.internalUpdateInProgress = false }
        self.current = self.queue.pop().map { IdentBox($0) }
    }
}

/// Gets ErrorQueue from Environment and presents errors
public struct ErrorQueuePresenter: ViewModifier {
    @EnvironmentObject private var viewModel: ErrorQueue
    public init() {}
    public func body(content: Content) -> some View {
        content.alert(item: self.$viewModel.current) { box in
            Alert(box.value, dismissAction: self.viewModel.update)
        }
    }
}

/// Clear view that gets ErrorQueue from Environment and presents errors
public struct ErrorQueuePresenterView: View {
    public init() {}
    public var body: some View {
        Color.clear.modifier(ErrorQueuePresenter())
    }
}
