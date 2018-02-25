//
//  SelectUsersViewController.swift
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
//  Created by Tudor Ana on 15/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

class SelectUsersViewController: BaseListViewController {
    
    lazy var usersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let timeSortDescriptor = NSSortDescriptor(key: "insertedTimestamp", ascending: true)
        request.sortDescriptors = [timeSortDescriptor]
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        if let _ = boardId {
            //Edit board
            var predicates = [NSPredicate(format: "following == true"), 
                              NSPredicate(format: "boardId == %@ || boardId == null", boardId!)]
            
            if let username = KeyChain.load(string: "username") {
                predicates = [NSPredicate(format: "username != %@ && following == true", username), 
                              NSPredicate(format: "boardId == %@ || boardId == null", boardId!)]
            }
            
            var compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.predicate = compoundPredicate
        } else {
            //Add new board
            var predicate = NSPredicate(format: "following == true AND boardId == null")
            if let username = KeyChain.load(string: "username") {
                predicate = NSPredicate(format: "username != %@ AND following == true AND boardId == null", username)
            }
            request.predicate = predicate
        }
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    var boardId: String?
    var boardName: String?
    var selectedUsers: [String] = []
    
    var designedPredicate: NSPredicate?
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBAction func nextAction(_ sender: Any) {
        performSegue(withIdentifier: "showAddBoardSegue", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        designedPredicate = usersFetchedResultsController.fetchRequest.predicate
        loadData(newer: true)
        
        //Show search bar
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set next button disabled until user completes name and users
        nextButton.isEnabled = self.canEnableNextButton()
    
    }
    
    override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    override func loadData(newer: Bool) {
        
        loading = true
        
        if newer == true {
            User.current { (user) in
                User.followings(of: user, { [weak self] (status) in
                    guard let _ = self else { return }
                    self!.loading = false
                })
            }
        } else {
            User.current { (user) in
                User.followings(of: user, { [weak self] (status) in
                    guard let _ = self else { return }
                    self!.loading = false
                    }, with: user.nextCursor!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddBoardSegue" {
            let destinationViewController = segue.destination as! AddBoardViewController
            destinationViewController.boardId = boardId
            destinationViewController.boardName = boardName
            destinationViewController.selectedUsers = selectedUsers
        }
    }
}


extension SelectUsersViewController {
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard let count = usersFetchedResultsController.fetchedObjects?.count,
            count > 0 else {
                infoHeaderView.show(nil)
                return self.infoHeaderView
        }
        infoHeaderView.show(String(format: "%ld available users", count))
        return infoHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        
        guard let user = usersFetchedResultsController.object(at: indexPath) as? User else {
            return cell
        }
        if selectedUsers.contains(user.objectId!) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        cell.show(user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let user = usersFetchedResultsController.object(at: indexPath) as? User else {
            return
        }
        if selectedUsers.contains(user.objectId!) {
            selectedUsers.remove(object: user.objectId!)
        } else {
            selectedUsers.append(user.objectId!)
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        nextButton.isEnabled = canEnableNextButton()
    }
}


extension SelectUsersViewController {
    
    func search(_ text: String) {
        
        let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [designedPredicate!, searchPredicate])
        
        usersFetchedResultsController.fetchRequest.predicate = compoundPredicate
        do {
            try usersFetchedResultsController.performFetch()
            
        } catch {
            console("Error perform fetch")
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func clear() {
        usersFetchedResultsController.fetchRequest.predicate = designedPredicate
        do {
            try usersFetchedResultsController.performFetch()
            
        } catch {
            console("Error perform fetch")
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}


extension SelectUsersViewController {
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else { clear() }
    }
}


extension SelectUsersViewController {
    
    func canEnableNextButton() -> Bool {
        
        if selectedUsers.count > 0 {
            return true
        }
        return false
    }
}
