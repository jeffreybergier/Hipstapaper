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
        
        @ViewBuilder var body: some View {
            if self.monitor.isLoggedIn == false {
                STZ.TB.CloudAccountError.toolbar {
                    self.errorQ.queue.append(Error.cloudAccount)
                }
            } else if self.monitor.errorQ.isEmpty == false {
                STZ.TB.CloudSyncError.toolbar {
                    while !self.monitor.errorQ.isEmpty {
                        self.errorQ.queue.append(self.monitor.errorQ.next()!)
                    }
                }
            }
        }
    }
}
