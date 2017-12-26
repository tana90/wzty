//
//  NewsfeedDetailsViewController.swift
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

final class NewsfeedDetailsViewController: BaseDetailsViewController {
    
    lazy var postFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        if let postT = post,
            let objectId = postT.objectId {
            let predicate = NSPredicate(format: "objectId == %@", objectId)
            request.predicate = predicate
        }
        request.sortDescriptors = []
        request.fetchLimit = 1
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform(postFetchResultsController)
    }
}

extension NewsfeedDetailsViewController {
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let post = postFetchResultsController.object(at: IndexPath(row: 0, section: 0)) as? Post else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        switch indexPath.row {
        case 0:
            let detailsCell = tableView.dequeueReusableCell(withIdentifier: "newsfeedDetailsCell") as! NewsfeedDetailsCell
            detailsCell.showImageActionHandler = { [unowned self] in
                let mediaPreview = MediaPreview(nibName: "MediaPreview", bundle: nil)
                self.present(mediaPreview, animated: true, completion: nil)
                mediaPreview.show(post.imageUrl)
            }
            detailsCell.show(post)
            return detailsCell
        case 1:
            let webViewCell = tableView.dequeueReusableCell(withIdentifier: "newsfeedWebCell") as! NewsfeedWebCell
            webViewCell.show(post)
            
            webViewCell.beginScrollHandler = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            }
            webViewCell.changeTitleHandler = { [weak self] title in
                guard let strongSelf = self else { return }
                strongSelf.navigationHeaderView.titleLabel.text = title
            }
            webViewCell.closeHandler = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView.isScrollEnabled = true
                strongSelf.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }

            return webViewCell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
}

