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
    @IBOutlet weak var mediaView: UIImageView!
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
    
    func show(_ post: Post, refreshable refresh: Bool = true) {
        
        targetUserId = post.userId
        targetPostId = post.objectId
        
        //User
        let predicate = NSPredicate(format: "objectId == %@", post.userId!)
        User.fetchBy(predicate: predicate) { [weak self](user) in
            guard let _ = user,
                let _ = self else { return }
            
            //User image
            if let imageUrlT = user!.userImageUrl {
                self!.userImageView?.kf.setImage(with: URL(string: imageUrlT))
            } else {
                self!.userImageView?.image = nil
            }
            
            //Username
            self!.usenameLabel?.text = user!.name
        }
        
        populateCell(withPost: post)
        
        //Fetch data and let NSFetchResultsController to reupdate cell
        if post.title == nil || post.imageUrl == nil {
            UrlDataPrefetcher.shared.fetch(link: post.link, completionHandler: { [weak self] in
                
                guard let _ = self else { return }
                self!.populateCell(withPost: post)
                if refresh {
                    CoreDataManager.shared.saveContextBackground()
                }
            })
        }
    }
    
    func populateCell(withPost: Post) {
        
        //Date
        let date = Date(timeIntervalSince1970: TimeInterval(withPost.timestamp)) as Date
        self.dateLabel?.text = date.getElapsedInterval(shortFormat: true)
        
        //Title
        titleLabel?.text = withPost.title
        
        //Details
        detailsLabel?.text = withPost.details
        
        //Show an activity spinner until picture is downloaded
        activityIndicatorView?.startAnimating()
        
        //Image
        if let imageUrlT = withPost.imageUrl {
            mediaView.kf.setImage(with: URL(string: imageUrlT))
            mediaView.alpha = 0.85
            activityIndicatorView?.stopAnimating()
        } else {
            mediaView?.image = nil
        }
    }
}
