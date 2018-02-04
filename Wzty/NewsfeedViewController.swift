//
//  NewsfeedViewController.swift
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
import CoreData

final class NewsfeedViewController: BaseListViewController {
    
    
    
    lazy var postFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        let timeSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timeSortDescriptor]
        let predicate = NSPredicate(format: "homeTimeline == true AND hidden == false")
        request.predicate = predicate
        request.fetchLimit = FETCH_LIMIT
        
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "NewsfeedCell", bundle: nil), forCellReuseIdentifier: "newsfeedCell")
        
        //Register for CoreData updates
        perform(postFetchResultsController)
        
        //Load first posts
        loadData(newer: true)
    }
    
    
    @objc override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    override func loadData(newer: Bool) {
        loading = true
        User.current { (user) in
            Post.homeTimeline(sinceId: newer ? user?.sinceId : nil,
                              maxId: newer ? nil : user?.maxId) { [weak self] (status) in
                                guard let _ = self else { return }
                                self!.loading = false
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
            return
        }
    }
}


//MARK: - TableView Delegate & DataSource
extension NewsfeedViewController {
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! NewsfeedCell
        guard let post = postFetchResultsController.object(at: indexPath) as? Post else {
            return cell
        }
        cell.show(post)
        cell.showUserDetailsActionHandler = { [unowned self] (userId) in
            self.targetUserId = userId
            self.performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNewsDetailsSegue", sender: self)
    }
}


//MARK: - TableView Prefetch DataSource
extension NewsfeedViewController: UITableViewDataSourcePrefetching {
    
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
