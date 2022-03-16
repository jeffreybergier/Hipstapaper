//
//  ModalPresentable.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2021/01/16.
//

import SwiftUI
import Umbrella
import Browse
import Datum2
import Stylize
import Snapshot
import Localize

struct BrowserPresentable: ViewModifier {
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.sheet(item: self.$presentation.isBrowser) { item in
            self.browser(item.preferredURL)
        }
        #else
        return content.fullScreenCover(item: self.$presentation.isBrowser) { item in
            self.browser(item.preferredURL)
        }
        #endif
    }
    
    private func browser(_ url: URL?) -> some View {
        Browser(url: url, doneAction: { self.presentation.value = .none })
    }
}

struct TagApplyPresentable: ViewModifier {
    
    let controller: Controller
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(item: self.$presentation.isTagApply)
        { selection in
            TagApply(controller: self.controller,
                     selection: selection.value,
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
    
    let controller: Controller
    @ErrorQueue private var errorQ
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    func body(content: Content) -> some View {
        content.sheet(isPresented: self.$presentation.isAddWebsite) {
            Snapshotter(.init(doneAction: self.snapshot))
        }
    }
    
    private func snapshot(_ result: Result<Snapshot.ViewModel.Output, Snapshot.Error>) {
        defer { self.presentation.value = .none }
        switch result {
        case .success(let output):
            let result2 = self.controller.createWebsite(.init(output))
            result2.error.map {
                self.errorQ = $0
                log.error($0)
            }
        case .failure(let error):
            self.errorQ = error
            log.error(error)
        }
    }
}

struct AddChoicePresentable: ViewModifier {
    
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.modifier(
            STZ.ACTN.Modifier(isPresented: self.$presentation.isAddChoose)
            {
                STZ.ACTN.Wrapper(title: Phrase.addChoice.rawValue,
                                 buttons: [
                                    self.addTagButton,
                                    self.addWebsiteButton
                                 ])
            }
        )
    }
    
    private var addTagButton: STZ.ACTN.Wrapper.Button {
        return .init(title: Verb.addTag.rawValue) {
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
        return .init(title: Verb.addWebsite.rawValue) {
            self.presentation.value = .none
            // TODO: Remove this hack when possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.presentation.value = .addWebsite
            }
        }
    }
}
