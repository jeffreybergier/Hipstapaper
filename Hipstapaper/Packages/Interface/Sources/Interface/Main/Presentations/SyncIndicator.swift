//
//  Created by Jeffrey Bergier on 2021/02/11.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI
import Umbrella
import Datum2
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
