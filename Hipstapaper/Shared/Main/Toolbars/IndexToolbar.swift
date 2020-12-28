//
//  Created by Jeffrey Bergier on 2020/12/05.
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
import Datum
import Localize
import Stylize
import Snapshot

struct IndexToolbar: ViewModifier {
    
    let controller: Controller
    @Binding var presentations: Presentation.Wrap
    
    func body(content: Content) -> some View {
        return ZStack(alignment: Alignment.topTrailing) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentations.isAddTag) {
                    AddTag(
                        cancel: { self.presentations.value = .none },
                        save: {
                            let result = self.controller.createTag(name: $0)
                            switch result {
                            case .success:
                                self.presentations.value = .none
                            case .failure(let error):
                                // TODO: Do something with this error
                                break
                            }
                        }
                    )
                }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .sheet(isPresented: self.$presentations.isAddWebsite) {
                    Snapshotter() { result in
                        switch result {
                        case .success(let output):
                            // TODO: maybe show error to user?
                            try! self.controller.createWebsite(.init(output)).get()
                        case .failure(let error):
                            // TODO: maybe show error to user?
                            break
                        }
                        self.presentations.value = .none
                    }
                }
            
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .modifier(ActionSheet(
                    isPresented: self.$presentations.isAddChoose,
                    title: Phrase.AddChoice,
                    buttons: [
                        .init(title: Verb.AddTag) {
                            self.presentations.value = .none
                            // TODO: Remove this hack when possible
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.presentations.value = .addTag
                            }
                        },
                        .init(title: Verb.AddWebsite) {
                            self.presentations.value = .none
                            // TODO: Remove this hack when possible
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.presentations.value = .addWebsite
                            }
                        }
                    ]
                ))
            
            content.toolbar(id: "Index") {
                ToolbarItem(id: "Index.0", placement: .confirmationAction) {
                    ButtonToolbar(systemName: "plus",
                                  accessibilityLabel: Verb.AddTag,
                                  action: { self.presentations.value = .addChoose })
                }
                
            }
        }
    }
}
