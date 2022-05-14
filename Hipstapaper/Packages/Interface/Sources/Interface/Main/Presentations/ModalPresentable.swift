//
//  ModalPresentable.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2021/01/16.
//

import SwiftUI
import Umbrella
import Datum
import Stylize
import Localize
import Browse
import WebsiteEdit

struct BrowserPresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    @ControllerProperty private var controller
    
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.sheet(item: self.$presentation.isBrowser) { item in
            self.browser(item)
        }
        #else
        return content.fullScreenCover(item: self.$presentation.isBrowser) { item in
            self.browser(item)
        }
        #endif
    }
    
    private func browser(_ website: Website) -> some View {
        Browser(website: website,
                controller: self.controller,
                doneAction: { self.presentation.value = .none })
    }
}

struct TagApplyPresentable: ViewModifier {
        
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(item: self.$presentation.isTagApply)
        { selection in
            TagApply(selection: selection.value,
                     done: { self.presentation.value = .none })
        }
    }
}

struct SharePresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(item: self.$presentation.isShare) { selection in
            STZ.SHR(items: selection.value.compactMap { $0.preferredURL },
                    completion:  { self.presentation.value = .none })
        }
    }
}

struct SearchPickerPresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isSearch)
        { SearchPicker { self.presentation.value = .none } }
    }
}

struct SortPickerPresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content
            .popover(isPresented: self.$presentation.isSort) {
                SortPicker { self.presentation.value = .none }
            }
    }
}

struct TagNamePickerPresentable: ViewModifier {
    
    @ControllerProperty private var controller
    @ErrorQueue private var errorQ
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    func body(content: Content) -> some View {
        content
            .popover(item: self.$presentation.isTagName) { id in
                TagNamePicker(id: id.value) {
                    self.presentation.value = .none
                } delete: {
                    self.presentation.value = .none
                    let error = DeleteError.tag {
                        TH.delete(id.value, self.controller, self._errorQ.environment)
                    }
                    // TODO: Delete this hack when its not needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.errorQ = error
                    }
                }
            }
    }
}

struct AddWebsitePresentable: ViewModifier {
    
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    @StateObject private var editorErrorQueue = ErrorQueue.newEnvirementObject()

    func body(content: Content) -> some View {
        content.sheet(item: self.$presentation.isEditWebsite) { payload in
            // TODO: Make multiedit
            WebsiteEditor(payload.value.0, payload.value.1) {
                self.presentation.isEditWebsite = nil
            }
            .environmentObject(self.editorErrorQueue)
        }
    }
}
