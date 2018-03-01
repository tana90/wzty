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
        let predicate = NSPredicate(format: "username LIKE[c] '' OR username CONTAINS[cd] '' OR name CONTAINS[cd] ''")
        request.predicate = predicate
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    lazy var trendsFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Trend")
        let sortDescritor = NSSortDescriptor(key: "objectId", ascending: true)
        request.sortDescriptors = [sortDescritor]
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return frc
    }()
    
    
    var lastSearchTimestamp: Int = 0
    var selectedSearchIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.register(UINib(nibName: "TrendCell", bundle: nil), forCellReuseIdentifier: "trendCell")
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        
        //Show search bar
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.showsCancelButton = false
        
        
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        Trend.sync { [weak self] (status) in
            guard let _ = self else { return }
            DispatchQueue.main.safeAsync {
                do {
                    try self!.trendsFetchResultsController.performFetch()
                } catch _ {
                    console("Error performing fetch products")
                }
                self!.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
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
    
    
    func search(_ text: String, suggested: Bool = false) {
        
        User.searchUsers(text) { [unowned self] (status, timestamp) -> (Void) in
            DispatchQueue.main.safeAsync {
                if text.count > Int(0) {
                    if self.lastSearchTimestamp < timestamp {
                        
                        var predicate = NSPredicate(format: "username == '%@' OR (username CONTAINS[cd] %@ OR name CONTAINS[cd] %@)", text, text)
                        
                        if suggested {
                            predicate = NSPredicate(format: "username LIKE[c] %@", text)
                        }
                        
                        self.usersFetchedResultsController.fetchRequest.predicate = predicate
                        do {
                            try self.usersFetchedResultsController.performFetch()
                        } catch {
                            console("Error perform fetch")
                        }
                        
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        self.lastSearchTimestamp = timestamp
                    }
                } else {
                    self.clear()
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
        searchBarDidSearch(searchText)
    }
    
    override func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
        guard let _ = searchBar.text else {
            clear()
            return
        }
        searchBarDidSearch(searchBar.text!)
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)
        clear()
    }
    
    func searchBarDidSearch(_ searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else {
            clear()
        }
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
        return showSearch() ? 90 : 55
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return showSearch() ? super.numberOfSections(in: tableView) : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showSearch() {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
        guard let _ = self.trendsFetchResultsController.fetchedObjects else { return 1 }
        return (self.trendsFetchResultsController.fetchedObjects?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showSearch() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
            guard let user = usersFetchedResultsController.object(at: indexPath) as? User else {
                return cell
            }
            cell.selectionStyle = .default
            cell.show(user)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "trendCell") as! TrendCell
        guard let trend = trendsFetchResultsController.object(at: indexPath) as? Trend else {
            return cell
        }
        cell.selectionStyle = .none
        cell.show(trend)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showSearch() {
            self.performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
        } else {
            guard let trend = trendsFetchResultsController.object(at: indexPath) as? Trend else {
                return
            }
            searchController.searchBar.text = trend.username!
            search(trend.username!, suggested: true)
        }
    }
}

extension ExploreViewController {
    
    func showSearch() -> Bool {
        guard let _ = usersFetchedResultsController.fetchedObjects else { return false }
        return (usersFetchedResultsController.fetchedObjects?.count)! > Int(0) ? true : false
    }
}

