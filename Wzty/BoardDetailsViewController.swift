//
//  BoardDetailsViewController.swift
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
//  Created by Tudor Ana on 17/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

class BoardDetailsViewController: BaseListViewController {
    
    lazy var postFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        let timeSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timeSortDescriptor]
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        if let boardT = board {
            var userPredicate = NSPredicate(format: "boardId == %@ AND following == true", boardT.objectId!)
            User.fetchAllBy(predicate: userPredicate, result: { (users) in
                
                if let usersT = users {
                    var predicates: [NSPredicate] = []
                    for user in usersT {
                        predicates.append(NSPredicate(format: "userId == %@ AND hidden == false", (user?.objectId)!))
                    }
                    
                    let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                    request.predicate = compoundPredicate
                }
                
            })
        }
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var board: Board?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load first posts
        loadData(newer: true)
        
        //Configure cell
        tableView.register(UINib(nibName: "NewsfeedCell", bundle: nil), forCellReuseIdentifier: "newsfeedCell")
        
        //Listen to posts change
        perform(postFetchResultsController)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = board {
            Board.fetchBy(id: board!.objectId!, result: { [weak self] (board) in
                guard let _ = board as? Board else { return }
                self?.title = (board as! Board).name
            })
        } 
    }
    
    @objc override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //Show post details
        if segue.identifier == "showNewsDetailsSegue" {
            let destination = segue.destination as? NewsfeedDetailsViewController
            guard let post = postFetchResultsController.object(at: tableView.indexPathForSelectedRow!) as? Post else {
                return
            }
            destination?.post = post
            return
        }
        
        //Edit board
        if segue.identifier == "showEditBoardSegue" { 
            let destination = segue.destination as? SelectUsersViewController
            guard let _ = board else {
                return
            }
            destination?.boardName = board!.name
            destination?.boardId = board!.objectId
            let predicate = NSPredicate(format: "boardId == %@ AND following == true", (board?.objectId!)!)
            var usersIds: [String] = []
            User.fetchAllBy(predicate: predicate) { (users) in
                if let _ = users {
                    for user in users! {
                        usersIds.append((user?.objectId!)!)
                    }
                    destination?.selectedUsers = usersIds
                }
            }
            return
        }
    }
    
    
    var blockOperations: [BlockOperation] = []
    
    override func loadData(newer: Bool) {
        loading = true
        
        if let boardT = board {
            let userPredicate = NSPredicate(format: "boardId == %@", boardT.objectId!)
            User.fetchAllBy(predicate: userPredicate, result: { (users) in
                
                
                if let usersT = users {
                    
                    var index = 0
                    for user in usersT {
                        
                        blockOperations.append(
                            BlockOperation(block: { [weak self] in
                                
                                Post.homeTimelineBy(userId: (user?.objectId)!, sinceId: newer ? user?.sinceId : nil,
                                                    maxId: newer ? nil : user?.maxId) { [weak self] (status) in
                                                        guard let _ = self else { return }
                                                        
                                                        index += 1
                                                        if index >= (users?.count)! {
                                                            self!.loading = false
                                                            CoreDataManager.shared.saveContextBackground()
                                                        }
                                                        
                                }
                            }))
                        
                    }
                    
                    for operation: BlockOperation in blockOperations {
                        operation.start()
                    }
                }
            })
        }
    }
}


//MARK: - TableView Delegate & DataSource
extension BoardDetailsViewController {
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! NewsfeedCell
        guard let post = postFetchResultsController.object(at: indexPath) as? Post else {
            return cell
        }
        
        cell.show(post, refreshable: indexPath.row == 0 ? true : false)
        cell.showUserDetailsActionHandler = { [unowned self] (userId) in
            self.targetUserId = userId
            self.performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNewsDetailsSegue", sender: self)
    }
}


//MARK: - TableView Prefetch DataSource
extension BoardDetailsViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView,
                   prefetchRowsAt indexPaths: [IndexPath]) {
        
        
        for indexPath in indexPaths {
            
            guard let post = postFetchResultsController.object(at: indexPath) as? Post,
                post.title == nil else {
                    return
            }
            
            //Fetch data and let NSFetchResultsController to reupdate cell
            if post.title == nil || post.imageUrl == nil {
                DataPrefetcher.shared.fetch(post: post, completion: { (completedPost) in
                    if (tableView.indexPathsForVisibleRows?.contains(indexPath))! {
                        CoreDataManager.shared.saveContextBackground()
                    }
                })
            }
        }
    }
}
