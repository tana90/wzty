//
//  AddBoardViewController.swift
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
//  Created by Tudor Ana on 2/22/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class AddBoardViewController: UICollectionViewController {
    
    var boardId: String?
    var boardName: String?
    var selectedUsers: [String] = []
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10.0, bottom: 10.0, right: 10.0)
    let sectionLineInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let itemsPerRow: CGFloat = 4
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = .lightGray
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
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
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register cell
        collectionView?.register(UINib(nibName: "SelectedUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "selectedUserCellIdentifier")
        
        //Show search bar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Board name"
        searchController.searchBar.setImage(UIImage(named: "boards"), for: .search, state: .normal)
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set save button disabled until user completes name and users
        saveButton.isEnabled = self.canEnableSaveButton()
        
        //Populate board name
        if let _ = boardName {
            searchController.searchBar.text = boardName!
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searchController.dismiss(animated: true, completion: nil)
    }
}

extension AddBoardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let width = (collectionView.frame.width - padding) / itemsPerRow
        return CGSize(width: width, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension AddBoardViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedUserCellIdentifier", for: indexPath) as! SelectedUserCollectionViewCell
        
        User.fetchBy(id: selectedUsers[indexPath.row]) { (user) in
            guard let _ = user else { return }
            cell.show(user! as? User)
        }
        return cell
    }
}

extension AddBoardViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let identifier = "addBoardHeaderView"

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)

        return headerView
    }
}



extension AddBoardViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.boardName = searchText
        self.saveButton.isEnabled = self.canEnableSaveButton()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension AddBoardViewController {
    
    func canEnableSaveButton() -> Bool {
        
        if let name = boardName,
            name.count > Int(0) && selectedUsers.count > 0 {
            return true
        }
        return false
    }
}
