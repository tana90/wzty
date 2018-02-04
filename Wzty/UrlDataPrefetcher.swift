//
//  UrlDataPrefetcher.swift
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
//  Created by Tudor Ana on 29/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class UrlDataPrefetcher {
    
    static let shared = UrlDataPrefetcher()
    private var urlsInProgress: [String] = []
    
    
    func fetch(link: String?, completionHandler: (()->())? = nil) {
        guard let _ = link,
            let url = URL(string: link!) else { return }
        
        if !urlsInProgress.contains(link!) {
            urlsInProgress.append(link!)
            
            url.fetchUrlMedia({ [unowned self] (title, details, image) in
                
                //Write infos to CoreData
                let predicate = NSPredicate(format: "link == %@", link!)
                Post.fetchBy(predicate) { (result) in
                    guard let _ = result else { 
                        self.urlsInProgress.remove(object: link!)
                        return
                    }
                    result!.title = title
                    result!.details = details
                    result!.imageUrl = image
                    
                    if let _ = image {
                        UIImageView().kf.setImage(with: URL(string: image!))
                    }
                    if let _ = completionHandler {
                        completionHandler!()
                    }
                    self.urlsInProgress.remove(object: link!)
                }
                
                
                
                }, failure: { [unowned self] (error) in
                    self.urlsInProgress.remove(object: link!)
            })
        }
    }
}
