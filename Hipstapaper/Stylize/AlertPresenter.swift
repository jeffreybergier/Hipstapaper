//
//  Created by Jeffrey Bergier on 2021/01/10.
//
//  Copyright © 2020 Saturday Apps.
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
import Stylize

extension Alert {
    public typealias DismissAction = (Error) -> Void
    public class ViewModel: ObservableObject {
        public var dismissAction: DismissAction?
        public var alert: Alert? {
            guard let error = self.error else { return nil }
            return Alert(error: error, dismissAction: self.dismissAction)
        }
        @Published public var error: LocalizedError? {
            didSet {
                let shouldBe = self.error != nil
                guard shouldBe != self.isPresented else { return }
                self.isPresented = shouldBe
            }
        }
        @Published internal var isPresented = false {
            didSet {
                guard self.isPresented == false else { return }
                self.error = nil
            }
        }
        public init() {}
    }
    public init(error: LocalizedError, dismissAction: DismissAction?) {
        self.init(title: Text("Error"),
                  message: Text(error.errorDescription!),
                  dismissButton: .default(Text("Dismiss"), action: { dismissAction?(error) }))
    }
}

public struct AlertPresenter: View {
    @ObservedObject public var viewModel: Alert.ViewModel
    public var body: some View {
        guard let alert = self.viewModel.alert else {
            return AnyView(Color.clear)
        }
        return AnyView(
            Color.clear
                .alert(isPresented: self.$viewModel.isPresented,
                       content: { alert })
        )
    }
    public init(_ viewModel: Alert.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
}

public struct AlertModifier: ViewModifier {
    @ObservedObject public var viewModel: Alert.ViewModel
    public func body(content: Content) -> some View {
        guard let alert = self.viewModel.alert else {
            return AnyView(content)
        }
        return AnyView(
            content
                .alert(isPresented: self.$viewModel.isPresented,
                       content: { alert })
        )
    }
    public var body: some View {
        guard let alert = self.viewModel.alert else {
            return AnyView(Color.clear)
        }
        return AnyView(
            Color.clear
                .alert(isPresented: self.$viewModel.isPresented,
                       content: { alert })
        )
    }
    public init(_ viewModel: Alert.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
}
