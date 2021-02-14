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
    
    @ObservedObject var monitor: AnySyncMonitor
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
        return self.monitor.progress.completedUnitCount < self.monitor.progress.completedUnitCount
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .modifier(STZ.PRG.BarMod(progress: self.monitor.progress,
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
        .onReceive(self.monitor.objectWillChange) { _ in
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
    
    // TODO: remove !
    // maybe create imagable protocol?
    @ViewBuilder private func build() -> some View {
        if self.monitor.errorQ.isEmpty {
            Image(systemName: STZ.TB.CloudSyncSuccess.icon!)
        } else if self.barIsVisible {
            Image(systemName: STZ.TB.CloudSyncInProgress.icon!)
        } else {
            Image(systemName: STZ.TB.CloudSyncError.icon!)
        }
    }
}