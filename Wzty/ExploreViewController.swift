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
        request.fetchLimit = FETCH_LIMIT
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var lastSearchTimestamp: Int = 0
    var focusSearchBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        
        if focusSearchBar {
            searchBar.becomeFirstResponder()
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
    
    
    func search(_ text: String) {
        if text.count > 0 {
            User.searchUsers(text) { [unowned self] (status, timestamp) -> (Void) in
                
                DispatchQueue.main.safeAsync { [weak self] in
                    
                    guard let _ = self else { return }
                    
                    if (self!.searchBar.text?.count)! > Int(0) {
                        
                        if self!.lastSearchTimestamp < timestamp {
                            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "searchCache")
                            let predicate = NSPredicate(format: "username CONTAINS[cd] %@ OR name CONTAINS[cd] %@", text, text)
                            self!.usersFetchedResultsController.fetchRequest.predicate = predicate
                            do {
                                try self!.usersFetchedResultsController.performFetch()
                            } catch {
                                console("Error perform fetch")
                            }
                            
                            self!.tableView.reloadData()
                            self!.lastSearchTimestamp = timestamp
                        }
                    }
                }
                
                
            }
            
        } else {
            clear()
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
        tableView.reloadData()
    }
}


extension ExploreViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else { clear() }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let _ = searchBar.text else { return }
        search(searchBar.text!)
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



extension ExploreViewController {
    
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
        performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
    }
}
