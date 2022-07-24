//
//  Created by Jeffrey Bergier on 2022/07/24.
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

import Combine
import SwiftUI

internal struct SyncIndicator: ViewModifier {
    
    @State private var progress: Progress
    @State private var showsSyncing: Bool = false
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common)
    @State private var timerToken: Cancellable?
    
    internal init(_ progress: Progress) {
        _progress = .init(initialValue: progress)
    }
    
    internal func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            Image(systemName: SystemImage.iCloudSync.rawValue)
                .modifier(SyncIndicatorOval())
                .ignoresSafeArea()
                .padding(.top, self.showsSyncing ? .syncOvalPaddingTop : 0)
                .opacity(self.showsSyncing ? 1 : 0)
        }
        .animation(.easeIn, value: self.showsSyncing)
        .onReceive(self.progress.publisher(for: \.fractionCompleted)) { value in
            guard self.isSyncing else { return }
            self.showsSyncing = true
            self.startTimer()
        }
        .onReceive(self.timer) { _ in
            guard self.isSyncing == false else { return }
            self.showsSyncing = false
            self.resetTimer()
        }
    }
    
    private var isSyncing: Bool {
        switch self.progress.fractionCompleted {
        case 0, 1: return false
        default: return true
        }
    }
    
    private func resetTimer() {
        self.timerToken?.cancel()
        self.timerToken = nil
        self.timer = Timer.publish(every: 3, on: .main, in: .common)
    }
    
    private func startTimer() {
        guard self.timerToken == nil else { return }
        self.timerToken = self.timer.connect()
    }
}
