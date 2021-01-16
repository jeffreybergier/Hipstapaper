//
//  Created by Jeffrey Bergier on 2021/01/16.
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


import WebKit
import Stylize

class ErrorDelegate: NSObject, WKNavigationDelegate {
    
    weak var errorQ: STZ.ERR.Q!
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.stopLoading()
        let localizedError = STZ.ERR.Legacy._LocalizedError(error: error as NSError)
        self.errorQ.append(localizedError)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.stopLoading()
        let localizedError = STZ.ERR.Legacy._LocalizedError(error: error as NSError)
        self.errorQ.append(localizedError)
    }
}
