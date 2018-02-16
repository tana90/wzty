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
    
    @IBOutlet weak var photoBarButtonItem: UIBarButtonItem!
    
    lazy var usersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let timeSortDescriptor = NSSortDescriptor(key: "insertedTimestamp", ascending: true)
        request.sortDescriptors = [timeSortDescriptor]
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        var predicate = NSPredicate(format: "following == true")
        if let username = KeyChain.load(string: "username") {
            predicate = NSPredicate(format: "username != %@ AND following == true", username)
        }
        
        request.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    @IBAction func settingsAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }
    
    @IBAction func profileDetailsAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showProfileDetailsSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        User.current(refreshable: true) { [unowned self] (user) in
            self.updateInfo(for: user)
        }
        
        //Register for CoreData updates
        perform(usersFetchedResultsController)
        loadData(newer: true)
    }
    
    func updateInfo(for user: User) {
        self.navigationItem.title = user.name
        guard let _ = user.userImageUrl else { return }
        
        UIImageView().kf.setImage(with: URL(string: user.userImageUrl!), placeholder: nil, options: nil, progressBlock: { (progress, maxProgress) in
            //
        }) { [weak self] (image, error, cache, url) in
            guard let _ = self else { return }
            self!.photoBarButtonItem.image = image?.roundedImage.kf.resize(to: CGSize(width: 35, height: 35), for: .aspectFit).withRenderingMode(.alwaysOriginal)
        }
    }
    
    override func refreshData() {
        super.refreshData()
        loadData(newer: true)
    }
    
    override func loadData(newer: Bool) {
        
        loading = true
        if newer == true {
            User.current(refreshable: true) { [unowned self] (user) in
                self.updateInfo(for: user)
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
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        
        User.current(refreshable: true) { [unowned self] (user) in
            if let count = user.followingsCount?.intValue,
                count > 0 {
                self.infoHeaderView.show(String(format: "%ld followings", count))
            } else {
                self.infoHeaderView.show("No followings")
            }
        }
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


