//
//  ExploreViewController.swift
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
//  Created by Tudor Ana on 13/12/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

final class ExploreViewController: BaseListViewController {
    
    lazy var usersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let timeSortDescriptor = NSSortDescriptor(key: "insertedTimestamp", ascending: false)
        let followSortDescriptor = NSSortDescriptor(key: "following", ascending: false)
        request.sortDescriptors = [followSortDescriptor, timeSortDescriptor]
        let predicate = NSPredicate(format: "username CONTAINS[cd] '' OR name CONTAINS[cd] ''")
        request.predicate = predicate
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()

    var lastSearchTimestamp: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        
        //Show search bar
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserDetailsSegue" {
            guard let user = usersFetchedResultsController.object(at: tableView.indexPathForSelectedRow!) as? User,
                let userId = user.objectId else {
                    return
            }
            let destinationViewController = segue.destination as! UserDetailsViewController
            destinationViewController.userId = userId
        }
    }
    
    
    func search(_ text: String) {
        
        User.searchUsers(text) { [unowned self] (status, timestamp) -> (Void) in
            
            DispatchQueue.main.safeAsync { [weak self] in
                
                guard let _ = self else { return }
                
                if text.count > Int(0) {
                    if self!.lastSearchTimestamp < timestamp {
                        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "searchCache")
                        let predicate = NSPredicate(format: "username CONTAINS[cd] %@ OR name CONTAINS[cd] %@", text, text)
                        self!.usersFetchedResultsController.fetchRequest.predicate = predicate
                        do {
                            try self!.usersFetchedResultsController.performFetch()
                        } catch {
                            console("Error perform fetch")
                        }
                        
                        self!.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        self!.lastSearchTimestamp = timestamp
                    }
                }
            }
        }
    }
    
    
    func clear() {
        let predicate = NSPredicate(format: "username CONTAINS[cd] '' OR name CONTAINS[cd] ''")
        usersFetchedResultsController.fetchRequest.predicate = predicate
        do {
            try usersFetchedResultsController.performFetch()
            
        } catch {
            console("Error perform fetch")
        }
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}


extension ExploreViewController {
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else { clear() }
    }
}



extension ExploreViewController {
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard let count = usersFetchedResultsController.fetchedObjects?.count,
            count > 0 else {
                infoHeaderView.show(nil)
                return self.infoHeaderView
        }
        infoHeaderView.show(String(format: "%ld results", count))
        return infoHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        
        guard let user = usersFetchedResultsController.object(at: indexPath) as? User else {
            return cell
        }
        
        cell.show(user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
    }
}
