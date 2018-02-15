//
//  UserDetailsViewController.swift
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
//  Created by Tudor Ana on 01/12/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

final class UserDetailsViewController: BaseListViewController {
    
    lazy var postFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        let timeSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timeSortDescriptor]
        
        if let userId = self.userId {
            let predicate = NSPredicate(format: "userId == %@ AND hidden == false", userId)
            request.predicate = predicate
        }
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    @IBOutlet weak var followButton: UIBarButtonItem!
    
    @IBAction func followAction() {
        if let userId = userId {
            
            let predicate = NSPredicate(format: "objectId == %@", userId)
            User.fetchBy(predicate: predicate) { (user) in
                
                User.follow(!(user?.following)!, (user?.objectId)!) { (status) in
                    
                    DispatchQueue.main.safeAsync { [weak self] in
                        self?.followButton.title = (user?.following)! ? "Unfollow" : "Follow"
                    }
                }
            }
            
            //Load first posts
            loadData(newer: true)
        }
    }
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "NewsfeedCell", bundle: nil), forCellReuseIdentifier: "newsfeedCell")
        
        //Listen to posts change
        perform(postFetchResultsController)
        
        if let userId = userId {
            let predicate = NSPredicate(format: "objectId == %@", userId)
            User.fetchBy(predicate: predicate) { (user) in
                DispatchQueue.main.safeAsync { [unowned self] in
                    self.navigationItem.title = user?.name
                    self.followButton.title = (user?.following)! ? "Unfollow" : "Follow"
                }
            }
            //Load first posts
            loadData(newer: true)
        }
    }
    
    
    @objc override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    
    override func loadData(newer: Bool) {
        loading = true
        
        if let userId = userId {
            let predicate = NSPredicate(format: "objectId == %@", userId)
            User.fetchBy(predicate: predicate) { (user) in
                guard let user = user else { return }
                Post.homeTimelineBy(userId: (user.objectId)!, sinceId: newer ? user.sinceId : nil, 
                                    maxId: newer ? nil : user.maxId) { [weak self] (status) in
                                        guard let _ = self else { return }
                                        self!.loading = false
                                        CoreDataManager.shared.saveContextBackground()
                                        
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showNewsDetailsSegue" {
            let destination = segue.destination as? NewsfeedDetailsViewController
            guard let post = postFetchResultsController.object(at: tableView.indexPathForSelectedRow!) as? Post else {
                return
            }
            destination?.post = post
        }
    }
    
}

//MARK: - TableView Delegate & DataSource
extension UserDetailsViewController {
    
    override func tableView(_ tableView: UITableView, 
                            viewForHeaderInSection section: Int) -> UIView? {
        
        if let userId = userId {
            let predicate = NSPredicate(format: "objectId == %@", userId)
            User.fetchBy(predicate: predicate) { [unowned self] (user) in
                if let username = user?.username {
                    self.infoHeaderView.show(String(format: "@%@", username))
                }
            }
        }
        return infoHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! NewsfeedCell
        guard let post = postFetchResultsController.object(at: indexPath) as? Post else {
            return cell
        }
        
        cell.show(post)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNewsDetailsSegue", sender: self)
    }
}


//MARK: - TableView Prefetch DataSource
extension UserDetailsViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView,
                   prefetchRowsAt indexPaths: [IndexPath]) {
        
        
        for indexPath in indexPaths {
            
            guard let post = postFetchResultsController.object(at: indexPath) as? Post,
                post.title == nil else {
                    return
            }
            
            //Fetch data and let NSFetchResultsController to reupdate cell
            if post.title == nil || post.imageUrl == nil {
                UrlDataPrefetcher.shared.fetch(link: post.link)
            }
        }
    }
}
