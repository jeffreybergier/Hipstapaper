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
