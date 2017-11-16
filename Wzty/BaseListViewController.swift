//
//  BaseListViewController.swift
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

class BaseListViewController: BaseCoreDataViewController {
    
    var loading: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) { [unowned self] in
            self.view.alpha = 1.0
            }.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Put refresh control
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }

    func loadData(newer: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) { [unowned self] in
            self.tableView.alpha = 0.1
            }.startAnimation()
    }
}



//MARK: - TableView Delegate & DataSource
extension BaseListViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let fetchResultsControllerT = fetchResultsController,
            let sections = fetchResultsControllerT.sections,
            sections.count > 0
            else {
                return 1
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchResultsControllerT = fetchResultsController,
            let sections = fetchResultsControllerT.sections,
            sections.count > 0 else { return 0 }
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let fetchResultsControllerT = fetchResultsController,
            let fetchedObjects = fetchResultsControllerT.fetchedObjects else {
            return
        }
        
        let last = fetchedObjects.count - 1
        if !loading && indexPath.row == last {
            //Load more
            loadData(newer: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell") as! NewsfeedCell
        return cell
    }
}
