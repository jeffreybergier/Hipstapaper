//
//  Created by Jeffrey Bergier on 2021/01/29.
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

import Stylize
import Datum
import SwiftUI

extension STZ.TB {
    struct SyncMonitor: View {
        
        @ObservedObject var monitor: AnySyncMonitor
        @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
        
        init(_ monitor: AnySyncMonitor) {
            _monitor = .init(wrappedValue: monitor)
        }
        
        var body: some View {
            if self.monitor.isLoggedIn == false {
                return AnyView(
                    STZ.TB.CloudAccountError.toolbar {
                        self.errorQ.append(Error.cloudAccount)
                    }
                )
            } else if self.monitor.errorQ.isEmpty == false {
                return AnyView(
                    STZ.TB.CloudSyncError.toolbar {
                        while !self.monitor.errorQ.isEmpty {
                            self.errorQ.append(self.monitor.errorQ.next()!)
                        }
                    }
                )
            } else if self.monitor.progress.completedUnitCount == self.monitor.progress.totalUnitCount {
                return AnyView(
                    STZ.TB.CloudSyncSuccess.toolbar(isEnabled: false, action: {})
                )
            } else {
                return AnyView(
                    // TODO: I can't get rid of the extra labels if I actually pass the Progress object
                    STZ.PRG.Spin(nil)
                )
            }
        }
    }
}
