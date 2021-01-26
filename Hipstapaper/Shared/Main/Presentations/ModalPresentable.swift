//
//  ModalPresentable.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2021/01/16.
//

import SwiftUI
import Browse
import Datum
import Stylize
import Snapshot
import Localize

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

struct TagApplyPresentable: ViewModifier {
    
    let controller: Controller
    let selectedWebsites: Set<AnyElement<AnyWebsite>>
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isTagApply)
            { () -> TagApply in
                TagApply(selectedWebsites: self.selectedWebsites,
                         controller: self.controller,
                         done: { self.presentation.value = .none })
            }
    }
}

struct SharePresentable: ViewModifier {
    
    let selectedWebsites: Set<AnyElement<AnyWebsite>>
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.popover(isPresented: self.$presentation.isShare)
            {
                STZ.SHR(items: self.selectedWebsites.compactMap { $0.value.preferredURL },
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
            // TODO: Do something with this error
            break
        }
    }
}

struct AddWebsitePresentable: ViewModifier {
    
    let controller: Controller
    @EnvironmentObject private var presentation: ModalPresentation.Wrap

    func body(content: Content) -> some View {
        content.sheet(isPresented: self.$presentation.isAddWebsite)
        {
            return Snapshotter(.init(doneAction: self.snapshot))
        }
    }
    
    private func snapshot(_ result: Result<Snapshot.ViewModel.Output, Snapshot.Error>) {
        switch result {
        case .success(let output):
            // TODO: maybe show error to user?
            _ = try! self.controller.createWebsite(.init(output)).get()
        case .failure(let error):
            // TODO: maybe show error to user?
            break
        }
        self.presentation.value = .none
    }
}

struct AddChoicePresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: ModalPresentation.Wrap
    
    func body(content: Content) -> some View {
        content.modifier(
            STZ.ACTN.Modifier(isPresented: self.$presentation.isAddChoose)
            {
                STZ.ACTN.Wrapper(title: Phrase.AddChoice,
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
