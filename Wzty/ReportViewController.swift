//
//  ReportViewController.swift
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
//  Created by Tudor Ana on 15/12/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit
import MessageUI

final class ReportViewController: UITableViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postSubtitleLabel: UILabel!
    @IBOutlet weak var unfollowLabel: UILabel! 
    var postId: String?
    
    @IBAction func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let postId = self.postId {
            let predicate = NSPredicate(format: "objectId == %@", postId)
            Post.fetchBy(predicate) { (post) in
                
                
                guard let _ = post else { return }
                
                //Title
                self.postTitleLabel?.text = post!.title
                
                //Details
                self.postSubtitleLabel?.text = post!.details
                
                //Image
                if let imageUrlT = post?.imageUrl {
                    postImageView?.kf.setImage(with: URL(string: imageUrlT))
                } else {
                    postImageView?.image = nil
                }
                
                
                let predicate = NSPredicate(format: "objectId == %@", (post?.userId)!)
                User.fetchBy(predicate: predicate) { (user) in

                    if user?.following == false {
                        DispatchQueue.main.safeAsync { [unowned self] in
                            self.unfollowLabel.alpha = 0.3
                        }
                    }
                }
            }
        } else {
            closeAction()
        }
        
    }
}

extension ReportViewController {
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Unfollow
        if indexPath.section == 1 {
            
            if let postId = self.postId {
                let predicate = NSPredicate(format: "objectId == %@", postId)
                Post.fetchBy(predicate) { (post) in
                    let predicate = NSPredicate(format: "objectId == %@", (post?.userId)!)
                    User.fetchBy(predicate: predicate) { (user) in
                        
                        if user?.following == true {
                            let alertViewController = UIAlertController(title: String(format: "Are you sure you want to unfollow %@", (user?.name)!), message: nil, preferredStyle: .alert)
                            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { (alert) in
                                
                                User.follow(false, (user?.objectId)!, { [unowned self] (status) in
                                    CoreDataManager.shared.delete(object: post!)
                                    self.navigationController?.popViewController(animated: true)
                                })
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                            }
                            
                            alertViewController.addAction(unfollowAction)
                            alertViewController.addAction(cancelAction)
                            self.present(alertViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        //Report
        if indexPath.section == 2 {
            
            if let postId = self.postId {
                let predicate = NSPredicate(format: "objectId == %@", postId)
                Post.fetchBy(predicate) { (post) in
                    let predicate = NSPredicate(format: "objectId == %@", (post?.userId)!)
                    
                    User.fetchBy(predicate: predicate) { (user) in
                        
                        let alertViewController = UIAlertController(title: String(format: "Are you sure you want to report %@", (user?.name)!), message: nil, preferredStyle: .alert)
                        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (alert) in
                            
                            User.report((user?.objectId)!) { [unowned self] (status) in
                                CoreDataManager.shared.delete(object: post!)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                        }
                        
                        alertViewController.addAction(reportAction)
                        alertViewController.addAction(cancelAction)
                        self.present(alertViewController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //Send feedback
        if indexPath.section == 3 {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ReportViewController: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self 
        
        mailComposerVC.setToRecipients(["contact@wztnews.com"])
        mailComposerVC.setSubject("Report issue")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
