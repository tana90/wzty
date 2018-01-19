//
//  AddNewBoardViewController.swift
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
//  Created by Tudor Ana on 15/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

class AddNewBoardViewController: BaseListViewController {
    
    lazy var usersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let timeSortDescriptor = NSSortDescriptor(key: "insertedTimestamp", ascending: true)
        request.sortDescriptors = [timeSortDescriptor]
        
        
        
        if let _ = boardId {
            var predicate = NSPredicate(format: "following == true")
            if let username = KeyChain.load(string: "username") {
                predicate = NSPredicate(format: "username != %@ AND following == true", username)
            }
            request.predicate = predicate
        } else {
            var predicate = NSPredicate(format: "following == true AND boardId == null")
            if let username = KeyChain.load(string: "username") {
                predicate = NSPredicate(format: "username != %@ AND following == true AND boardId == null", username)
            }
                request.predicate = predicate
        }
        request.fetchLimit = 50
        
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
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func saveAction(_ sender: Any) {
        if let _ = boardId {
            Board.fetchBy(id: boardId!, result: { (object) -> (Void) in
                if let board = object as? Board {
                    board.name = boardName
                    board.edit(selectedUsers)
                }
            })
        } else {
            Board.add(boardName!, selectedUsers)
        }
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        //Set save button disabled until user completes name and users
        saveButton.isEnabled = false
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        loadData(newer: true)
        
        if let _ = boardId {
            title = "Edit board"
        }
    }
    
    override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    override func loadData(newer: Bool) {
        
        loading = true
        
        if newer == true {
            User.current { (user) in
                User.followings(of: user, { [unowned self] (status) in
                    self.loading = false
                })
            }
        } else {
            User.current { (user) in
                User.followings(of: user, { [unowned self] (status) in
                    self.loading = false
                    }, with: user.nextCursor!)
            }
        }
    }
}


extension AddNewBoardViewController {

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UINib(nibName: "AddBoardHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? AddBoardHeaderView
        header?.changeNameHandler = { [unowned self] (name) in
            self.boardName = name
            self.saveButton.isEnabled = self.canEnableSaveButton()
        }
        if let _ = boardName {
            header?.textField?.text = boardName!
        } else {
            header?.textField?.becomeFirstResponder()
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
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
        
        saveButton.isEnabled = canEnableSaveButton()
    }
}


extension AddNewBoardViewController {
    
    func canEnableSaveButton() -> Bool {
        
        if let name = boardName,
            name.count > Int(0) && selectedUsers.count > 0 {
            return true
        }
        return false
    }
}
