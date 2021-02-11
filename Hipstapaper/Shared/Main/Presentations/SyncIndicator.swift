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
        
    private var barIsVisible: Bool {
        return self.monitor.progress.completedUnitCount < self.monitor.progress.completedUnitCount
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .modifier(STZ.PRG.BarMod(progress: self.monitor.progress,
                                         isVisible: self.barIsVisible))
            STZ.VIEW.Oval {
                if self.monitor.errorQ.isEmpty {
                    Image(systemName: STZ.TB.CloudSyncSuccess.icon!)
                        .modifier(STZ.FNT.OvalIndicator.apply())
                } else {
                    Image(systemName: STZ.TB.CloudSyncError.icon!)
                        .modifier(STZ.FNT.OvalIndicator.apply())
                }
            }
            .modifier(STZ.PDG.Equal())
            .offset(x: 0, y: self.iconIsVisible ? 0 : -100)
            .opacity(self.iconIsVisible ? 1 : 0)
            .animation(.spring())
        }
        .onReceive(self.monitor.objectWillChange) { _ in
            self.iconIsVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                self.iconIsVisible = false
            }
        }
    }
}
