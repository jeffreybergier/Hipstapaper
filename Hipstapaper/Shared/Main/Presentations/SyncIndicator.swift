//
//  Created by Jeffrey Bergier on 2021/02/11.
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
import Stylize

struct SyncIndicator: ViewModifier {
    
    @ObservedObject var progress: AnyContinousProgress
    @State private var iconIsVisible = false
    @State private var timer: Timer?
    
    private var scaleEffect: CGFloat {
        self.iconIsVisible ? 1 : 0.8
    }
    private var offset: CGFloat {
        self.iconIsVisible ? 0 : -15
    }
    private var opacity: Double {
        self.iconIsVisible ? 1 : 0
    }
    private var barIsVisible: Bool {
        return self.progress.progress.completedUnitCount < self.progress.progress.completedUnitCount
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .modifier(STZ.PRG.BarMod(progress: self.progress.progress,
                                         isVisible: self.barIsVisible))
            STZ.VIEW.Oval {
                self.build()
                    .modifier(STZ.FNT.OvalIndicator.apply())
                    .modifier(STZ.CLR.TB.Tint.foreground())
            }
            .modifier(STZ.PDG.Equal())
            .offset(x: 0, y: self.offset)
            .scaleEffect(x: self.scaleEffect, y: self.scaleEffect, anchor: .top)
            .opacity(self.opacity)
            .animation(.default)
            .allowsHitTesting(false)
        }
        .onReceive(self.progress.objectWillChange) { _ in
            self.iconIsVisible = true
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {
                $0.invalidate()
                self.timer = nil
                self.iconIsVisible = false
            }
        }
    }
    
    private func build() -> some View {
        if self.progress.errorQ.queue.isEmpty {
            return STZ.ICN.cloudSyncSuccess
        } else if self.barIsVisible {
            return STZ.ICN.cloudSyncInProgress
        } else {
            return STZ.ICN.cloudError
        }
    }
}
