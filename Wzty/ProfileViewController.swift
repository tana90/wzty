//
//  ProfileViewController.swift
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

final class ProfileViewController: BaseListViewController {
    
    lazy var usersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let timeSortDescriptor = NSSortDescriptor(key: "insertedTimestamp", ascending: true)
        request.sortDescriptors = [timeSortDescriptor]
        
        var predicate = NSPredicate(format: "following == true")
        if let username = KeyChain.load(string: "username") {
            predicate = NSPredicate(format: "username != %@ AND following == true", username)
        }
        
        request.predicate = predicate
        request.fetchLimit = 50
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    @IBAction func settingsAction(_ sender: Any) {
        performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        User.current { [unowned self] (user) in
            self.navigationItem.title = user.name
        }
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        loadData(newer: true)
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
}

extension ProfileViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
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
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showUserDetailsSegue", sender: self)
    }
}

