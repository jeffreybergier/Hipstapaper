//
//  ModalPresentable.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2021/01/16.
//

import SwiftUI
import Umbrella
import Browse
import Datum
import Stylize
import Snapshot
import Localize

struct BrowserPresentable: ViewModifier {
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.sheet(item: self.$presentation.isBrowser) { item in
            self.browser(item.value.value.preferredURL)
        }
        #else
        return content.fullScreenCover(item: self.$presentation.isBrowser) { item in
            self.browser(item.value.value.preferredURL)
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
                     selection: selection,
                     done: { self.presentation.value = .none })
        }
    }
}

struct SharePresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(item: self.$presentation.isShare) { selection in
            STZ.SHR(items: selection.compactMap { $0.value.preferredURL },
                    completion:  { self.presentation.value = .none })
        }
    }
}

struct SearchPresentable: ViewModifier {
    
    @Binding var search: String
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isSearch)
        {
            Search(searchString: self.$search,
                   doneAction: { self.presentation.value = .none })
        }
    }
}

struct SortPresentable: ViewModifier {
    
    @Binding var sort: Datum.Sort!
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isSort)
        {
            Sort(selection: self.$sort,
                 doneAction: { self.presentation.value = .none })
        }
    }
}

struct AddTagPresentable: ViewModifier {
    
    let controller: Controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    @EnvironmentObject private var errorQ: ErrorQueue

    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isAddTag)
        {
            AddTag(cancel: { self.presentation.value = .none },
                   save: self.save)
        }
    }
    
    private func save(_ name: String?) {
        let result = self.controller.createTag(name: name)
        switch result {
        case .success:
            self.presentation.value = .none
        case .failure(let error):
            self.errorQ.queue.append(error)
        }
    }
}

struct AddWebsitePresentable: ViewModifier {
    
    let controller: Controller
    @EnvironmentObject private var errorQ: ErrorQueue
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
                self.errorQ.queue.append($0)
                log.error($0)
            }
        case .failure(let error):
            self.errorQ.queue.append(error)
            log.error(error)
        }
    }
}

struct AddChoicePresentable: ViewModifier {
    
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
        return .init(title: Verb.AddTag) {
            self.presentation.value = .none
            // TODO: Remove this hack when possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.presentation.value = .addTag
            }
        }
    }
    
    private var addWebsiteButton: STZ.ACTN.Wrapper.Button {
        return .init(title: Verb.AddWebsite) {
            self.presentation.value = .none
            // TODO: Remove this hack when possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.presentation.value = .addWebsite
            }
        }
    }
}
