//
//  ModalPresentable.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2021/01/16.
//

import SwiftUI
import Browse

struct BrowserPresentable: ViewModifier {
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    func body(content: Content) -> some View {
        content.sheet(isPresented: self.$presentation.isBrowser) {
            // TODO: Do something if preferred URL nil
            Browser(url: self.presentation.browserItem!.value.preferredURL!,
                    doneAction: { self.presentation.value = .none })
        }
    }
}
