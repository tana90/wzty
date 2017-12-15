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
    
    
    func startFetch(link: String?) {
        
        guard let linkT = link,
            let url = URL(string: linkT) else { return }
        
        if !urlsInProgress.contains(linkT) {
            urlsInProgress.append(linkT)
            
            url.fetchUrlMedia({ [unowned self] (title, details, image) in
                
                //Write infos to CoreData
                let predicate = NSPredicate(format: "link == %@", linkT)
                Post.fetchBy(predicate) { (result) in
                    guard let resultT = result else { 
                        self.urlsInProgress.remove(object: linkT)
                        return
                    }
                    resultT.title = title
                    resultT.details = details
                    resultT.imageUrl = image
                    
                    if let imageT = image {
                        UIImageView().kf.setImage(with: URL(string: imageT))
                    }
                    CoreDataManager.shared.saveContextBackground()
                    self.urlsInProgress.remove(object: linkT)
                }
                
                

                }, failure: { [unowned self] (error) in
                    self.urlsInProgress.remove(object: linkT)
            })
        }
    }
    
    
    
}
