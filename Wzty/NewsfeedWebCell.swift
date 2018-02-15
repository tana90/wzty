//
//  NewsfeedWebCell.swift
//  Wzty
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Tudor Ana on 11/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class NewsfeedWebCell: UITableViewCell {
    
    @IBOutlet private weak var webView: UIWebView!
    
    public var finishHandler: (() -> ())?
    public var changeTitleHandler: ((String) -> ())?
    public var beginScrollHandler: (() -> ())?
    public var closeHandler: (() -> ())?
    private var isStarted: Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
    }
    
    func show(_ post: Post) {
        if !isStarted {
            DispatchQueue.main.safeAsync { [weak self] in
                guard let _ = self else { return }
                self!.webView.loadRequest(URLRequest(url: URL(string: post.link!)!))
            }
            self.isStarted = true  
        }
    }
}

extension NewsfeedWebCell: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if let handler = changeTitleHandler {
            var host = webView.request?.url?.host
            if (host?.hasPrefix("www."))! {
                host = host?.replacingOccurrences(of: "www.", with: "")
            }
            handler(host ?? "")
        }
    }
}


extension NewsfeedWebCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let handler = beginScrollHandler {
            handler()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -44 {
            guard let _ = closeHandler else { return }
            closeHandler!()
        }
    }
}
