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
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    func body(content: Content) -> some View {
        content
            .popover(item: self.$presentation.isTagName) { id in
                TagNamePicker(id: id.value) {
                    self.presentation.value = .none
                }
            }
    }
}

struct AddWebsitePresentable: ViewModifier {
    
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    func body(content: Content) -> some View {
        content.sheet(item: self.$presentation.isEditWebsite) { selection in
            // TODO: Make multiedit
            WebsiteEdit(selection.value.first!) {
                self.presentation.isEditWebsite = nil
            }
        }
    }
}

struct AddChoicePresentable: ViewModifier {
    
    @Localize private var text
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.modifier(
            STZ.ACTN.Modifier(isPresented: self.$presentation.isAddChoose)
            {
                STZ.ACTN.Wrapper(title: Phrase.addChoice.loc(self.text),
                                 buttons: [
                                    self.addTagButton,
                                    self.addWebsiteButton
                                 ],
                                 bundle: self.text)
            }
        )
    }
    
    private var addTagButton: STZ.ACTN.Wrapper.Button {
        return .init(title: Verb.addTag.loc(self.text)) {
            self.presentation.value = .none
            // TODO: Remove this hack when possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                switch self.controller.createTag() {
                case .success(let id):
                    self.presentation.value = .tagName(id)
                case .failure(let error):
                    self.errorQ = error
                }
            }
        }
    }
    
    private var addWebsiteButton: STZ.ACTN.Wrapper.Button {
        return .init(title: Verb.addWebsite.loc(self.text)) {
            self.presentation.value = .none
            // TODO: Remove this hack when possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                switch self.controller.createWebsite(nil) {
                case .success(let website):
                    self.presentation.value = .editWebsite([website])
                case .failure(let error):
                    self.errorQ = error
                }
            }
        }
    }
}
