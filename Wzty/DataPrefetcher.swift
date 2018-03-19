//
//  DataPrefetcher.swift
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
//  Created by Tudor Ana on 29/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class DataPrefetcher {
    
    static let shared = DataPrefetcher()
    private var urlsInProgress: [URL] = []
    
    func fetch(post: Post?, completion: ((Post)->())? = nil) {
        guard let post = post,
            let _ = post.link,
            let url = URL(string: post.link!) else { return }
        if !urlsInProgress.contains(url) {
            urlsInProgress.append(url)
            
            url.fetchUrlMedia({ (title, details, imageUrl) in
                post.title = title
                post.details = details
                post.imageUrl = imageUrl
                if let _ = completion {
                    completion!(post)
                }
                self.urlsInProgress.remove(object: url)
            }, failure: { (error) in
                self.urlsInProgress.remove(object: url)
            })
        }
    }
}
