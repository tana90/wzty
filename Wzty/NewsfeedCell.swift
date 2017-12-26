//
//  NewsfeedCell.swift
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
//  Created by Tudor Ana on 04/11/2017.
//

import UIKit

class NewsfeedCell: UITableViewCell {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var usenameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mediaViewContainer: UIView?
    @IBOutlet private weak var mediaView: UIImageView!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView?
    
    public var showUserDetailsActionHandler: ((String) -> ())?
    public var showMoreActionsHandler: ((String) -> ())?
    var targetUserId: String?
    var targetPostId: String?
    
    @IBAction func userDetailsAction() {
        if let handler = showUserDetailsActionHandler,
            let targetUserIdT = targetUserId {
            handler(targetUserIdT)
        }
    }
    
    @IBAction func moreAction() {
        
        if let handler = showMoreActionsHandler,
            let targetPostIdT = targetPostId {
            handler(targetPostIdT)
        }
        
    }
    
    func prefetch(_ post: Post) {
        guard let imageUrlT = post.imageUrl else { return }
        mediaView?.kf.setImage(with: URL(string: imageUrlT))
        targetUserId = post.userId!
        targetPostId = post.objectId!
    }
    
    
    func show(_ post: Post) {
        
        targetUserId = post.userId
        targetPostId = post.objectId
        
        //User
        let predicate = NSPredicate(format: "objectId == %@", post.userId!)
        User.fetchBy(predicate: predicate) { (user) in
            guard let userT = user else { return }
            DispatchQueue.main.safeAsync { [weak self] in
                
                guard let strongSelf = self else { return }
                //User image
                if let imageUrlT = userT.userImageUrl {
                    strongSelf.userImageView?.kf.setImage(with: URL(string: imageUrlT))
                } else {
                    strongSelf.userImageView?.image = nil
                }
                
                //Username
                strongSelf.usenameLabel?.text = userT.name
            }
        }
        
        
        
        //Date
        let date = Date(timeIntervalSince1970: TimeInterval(post.timestamp)) as Date
        self.dateLabel?.text = date.getElapsedInterval(shortFormat: true)
        
        //Title
        titleLabel?.text = post.title
        
        //Details
        detailsLabel?.text = post.details
        
        
        activityIndicatorView?.startAnimating()
        
        //Image
        if let imageUrlT = post.imageUrl {
            mediaView.kf.setImage(with: URL(string: imageUrlT), placeholder: nil, options: nil, progressBlock: { (progress, maxProgress) in
            }, completionHandler: { [weak self] (image, error, cacheType, url) in
                guard let strongSelf = self else { return }
                strongSelf.activityIndicatorView?.stopAnimating()
                
                if (error != nil) {
                    strongSelf.mediaView?.image = UIImage(named: "placeholder")
                }
                
                UIView.animate(withDuration: 0.30, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.mediaView.alpha = 1.0
                })
            })
        } else {
            mediaView?.image = nil
        }
        
        
        //Fetch data and let NSFetchResultsController to reupdate cell
        if post.title == nil {
            UrlDataPrefetcher.shared.startFetch(link: post.link)
        }
    }
}
